require "helper"
require "fluent/plugin/formatter_jq.rb"

class JqFormatterTest < Test::Unit::TestCase
  setup do
    Fluent::Test.setup
  end

  test "it should require jq_program" do
    assert_raise(Fluent::ConfigError) { create_driver '' }
  end

  test "it should raise error on invalid jq program" do
    e = assert_raise(Fluent::ConfigError) { create_driver 'jq_program blah' }
    assert_match /compile error/, e.message
  end

  test "it should work" do
    d = create_driver 'jq_program .log'
    record = {"log" => "this is a log", "source" => "stdout"}
    text = d.instance.format("some.tag", event_time, record)
    assert_equal record["log"], text
  end

  test "it should ignore error by default" do
    d = create_driver 'jq_program .[1]'
    record = {"log" => "some message"}
    text = d.instance.format "some.tag", event_time, record
    assert_equal record.to_json, text
  end

  test "it can skip on error" do
    d = create_driver "jq_program .[1]\non_error skip"
    record = {"log" => "some message"}
    text = d.instance.format "some.tag", event_time, record
    assert_equal '', text
  end

  test "it can raise error on error" do
    d = create_driver "jq_program .[1]\non_error raise_error"
    record = {"log" => "some message"}
    assert_raise(RuntimeError) {
      d.instance.format "some.tag", event_time, record
    }
  end

  private

  def create_driver(conf)
    Fluent::Test::Driver::Formatter.new(Fluent::Plugin::JqFormatter).configure(conf)
  end
end
