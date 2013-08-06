require 'helper'

module Dummy
  class IntVarEvent
    def var_type ; :var_type end
    def value    ; :value    end
  end
end

class MysqlBinlogInputTest < Test::Unit::TestCase
  def setup
    Fluent::Test.setup
  end

  CONFIG = %[
    host            localhost
    port            3306
    tag             input.mysql
    position_file   position.log
    listen_event    row_event
  ]

  def create_driver(conf=CONFIG, tag='test')
    Fluent::Test::OutputTestDriver.new(Fluent::MysqlBinlogInput, tag).configure(conf)
  end

  def test_configure
    assert_raise(Fluent::ConfigError) {
      d = create_driver('')
    }
    d = create_driver %[
      host            localhost
      port            3306
      tag             input.mysql
      position_file   position.log
      listen_event    row_event
    ]
    assert_equal 'localhost', d.instance.host
    assert_equal 3306, d.instance.port
    assert_equal 'input.mysql', d.instance.tag
    assert_equal 'row_event', d.instance.listen_event
  end

  def test_binlog_util
    assert_not_nil Fluent::MysqlBinlogInput::BinlogUtil.to_hash(Dummy::IntVarEvent.new)
    assert_not_nil Fluent::MysqlBinlogInput::BinlogUtil.attributes_for(:base)

  end
end
