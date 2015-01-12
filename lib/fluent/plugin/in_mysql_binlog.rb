module Fluent

  class MysqlBinlogInput < Input
    Plugin.register_input('mysql_binlog', self)

    def initialize
      super
      require 'kodama'
    end

    config_param :tag, :string
    config_param :host, :string, :default => 'localhost'
    config_param :port, :integer, :default => 3306
    config_param :username, :string, :default => 'root'
    config_param :password, :string, :default => nil
    config_param :position_file, :string, :default => 'position.log'
    config_param :retry_wait, :integer, :default => 3
    config_param :retry_limit, :integer, :default => 100
    config_param :log_level, :string, :default => 'info'
    config_param :listen_event, :string, :default => nil

    def configure(conf)
      super
      @listen_event ||= BinlogUtil::EVENT_TYPES.join(',')
      @listen_events = @listen_event.split(',').map {|i| i.strip }
    end

    def start
      $log.debug "listening mysql replication on #{mysql_url}"
      @thread = Thread.new(&method(:run))
    end

    def shutdown
      Thread.kill(@thread)
    end

    def run
      Kodama::Client.start(mysql_url) do |c|
        c.binlog_position_file = @position_file
        c.connection_retry_limit = @retry_limit
        c.connection_retry_wait = @retry_wait
        c.log_level = @log_level.to_sym
        c.gracefully_stop_on :QUIT, :INT
        @listen_events.each do |event_type|
          $log.trace { "registered binlog event listener '#{event_type}'" }
          c.send("on_#{event_type}", &method(:event_listener))
        end
      end
    end

    def event_listener(event)
      Engine.emit(@tag, Engine.now, BinlogUtil.to_hash(event))
    end

    def mysql_url
      {
        host: @host,
        port: @port,
        username: @username,
        password: @password,
      }
    end

    class BinlogUtil
      require 'active_support'

      EVENT_TYPES = %w(query_event rotate_event int_var_event user_var_event format_event xid table_map_event row_event incident_event unimplemented_event)

      TYPE_ATTRIBUTES = {
        base: %w(marker timestamp type_code server_id event_length next_position flags event_type),
        format_event: %w(binlog_version created_ts log_header_len),
        incident_event: %w(incident_type message),
        int_var_event: %w(var_type value),
        query_event: %w(thread_id exec_time error_code variables db_name query),
        rotate_event: %w(binlog_file binlog_pos),
        row_event: %w(table_id db_name table_name columns columns_len null_bits_len raw_columns_before_image raw_used_columns raw_row rows),
        table_map_event: %w(table_id db_name table_name raw_columns columns metadata null_bits),
        unimplemented_event: nil,
        user_var_event: %w(name is_null var_type charset value),
        xid: %w(xid_id),
      }

      class << self
        def to_hash(event)
          event_hash = {}
          attributes_for(event).map do |attr|
            begin
              event_hash[attr] = event.send(attr.to_sym)
              event_hash[attr + '_is_error'] = false
            rescue => e
              require 'json'
              event_hash[attr] = e.inspect + "\n" + e.backtrace.join("\n")
              event_hash[attr + '_is_error'] = true
              $log.error event_hash.to_json
            end
          end
          event_hash
        end

        def attributes_for(event)
          event_type = ActiveSupport::Inflector.underscore(
            ActiveSupport::Inflector.demodulize(event.class)
          ).gsub(/^on_/, '')
          TYPE_ATTRIBUTES[:base] + (TYPE_ATTRIBUTES[event_type.to_sym] || [])
        end
      end
    end

  end
end
