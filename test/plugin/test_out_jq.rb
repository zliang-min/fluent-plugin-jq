# frozen_string_literal: true

require "helper"
require "fluent/test/driver/output"
require "fluent/plugin/out_jq"

class JqOutputTest < Test::Unit::TestCase
  setup do
    Fluent::Test.setup
  end

  test "it should require jq" do
    assert_raise(Fluent::ConfigError) { create_driver '' }
  end

  test "it should raise error on invalid jq program" do
    e = assert_raise(Fluent::ConfigError) { create_driver 'jq blah' }
    assert_match(/compile error/, e.message)
  end

  test "it should work on tag" do
    events = create_driver('jq "{tag}"').events
    assert_equal events.size, 1
    assert_equal events[0][2]["tag"], "some.tag"
  end

  test "it should work on time" do
    events = create_driver('jq "{time: .time | gmtime }"').events
    assert_equal events.size, 1
    assert_equal events[0][2]["time"][0..5], [2018, 2, 22, 1, 23, 45]
  end

  test "it should support array" do
    events = create_driver('jq ".record | to_entries"').events.map { |evt| evt[2] }
    assert_equal events.size, 2
    assert_include events, {"key" => "log", "value" => "this is a log"}
    assert_include events, {"key" => "source", "value" => "stdout"}
  end

  test "it should remove specified tag prefix" do
    events = create_driver(<<~CONF).events
      jq ".record"
      remove_tag_prefix some
    CONF

    assert_equal events.size, 1
    assert_equal events[0][0], "tag"
  end

  private

  def create_driver(conf)
    Fluent::Test::Driver::Output.new(Fluent::Plugin::JqOutput).configure(conf).tap { |d|
      time = event_time("2018-03-22 01:23:45 UTC")
      d.run { d.feed "some.tag", time, {"log" => "this is a log", "source" => "stdout"} }
    }
  end
end
