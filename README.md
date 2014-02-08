fluent-plugin-mysql-binlog, a plugin for [Fluentd](http://fluentd.org)
===========================

MySQL Binlog input plugin for Fluentd event collector.

## Installation

Add this line to your application's Gemfile:

    gem 'fluent-plugin-mysql-binlog'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install fluent-plugin-mysql-binlog

## Configuration

### Config Sample
`````
<source>
  type            mysql_binlog
  host            localhost           # Optional (default: localhost)
  port            3306                # Optional (default: 3306)
  username        msandbox            # Optional (default: root)
  password        msadnbox            # Optional (default nopassword)
  tag             input.mysql         # Required
  position_file   position.log        # Optional (default: position.log)
  retry_wait      3                   # Optional (default: 3)
  retry_limit     100                 # Optional (default: 100)
  log_level       debug               # Optional (default: info)
  listen_event    row_event           # Optional (default: Fluent::MysqlBinlogInput::BinlogUtil::EVENT_TYPES.join(','))
</source>
`````


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
