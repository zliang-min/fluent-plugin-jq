# frozen_string_literal: true

require "helper"
require "fluent/test/driver/filter"
require "fluent/plugin/filter_jq_transformer"

class JqTransformerFilterTest < Test::Unit::TestCase
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
    d = create_driver 'jq "{tag}"'
    record = {"log" => "this is a log", "source" => "stdout"}
    record = d.instance.filter("some.tag", event_time, record)
    assert_equal record["tag"], "some.tag"
  end

  test "it should work on time" do
    d = create_driver 'jq "{time: .time | gmtime }"'
    now = event_time
    record = {"log" => "this is a log", "source" => "stdout"}
    record = d.instance.filter("some.tag", now, record)
    assert_equal record["time"][0..5],
      Time.at(now).utc.to_a[0..5].reverse.tap { |a| a[1] = a[1] - 1 }
  end

  test "it should work on record" do
    d = create_driver 'jq "{message: .record.log, stream: .record.source}"'
    record = {"log" => "this is a log", "source" => "stdout"}
    record = d.instance.filter("some.tag", event_time, record)
    assert_equal record["message"], "this is a log"
    assert_equal record["stream"], "stdout"
  end

  test "it should skip if it does not return a hash" do
    record = {"log" => "this is a log", "source" => "stdout"}

    d = create_driver 'jq ".tag"'
    assert_nil d.instance.filter("some.tag", event_time, record)

    d = create_driver 'jq ".time"'
    assert_nil d.instance.filter("some.tag", event_time, record)

    d = create_driver 'jq "[.time]"'
    assert_nil d.instance.filter("some.tag", event_time, record)
  end

  test "it should only return one object" do
    d = create_driver 'jq ".record, {tag, time}"'
    event = {"log" => "this is a log", "source" => "stdout"}
    record = d.instance.filter("some.tag", event_time, event)
    assert_equal event, record
  end

  private

  def create_driver(conf)
    Fluent::Test::Driver::Filter.new(Fluent::Plugin::JqTransformerFilter).configure(conf)
  end
end
