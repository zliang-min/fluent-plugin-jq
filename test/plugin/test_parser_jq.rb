# frozen_string_literal: true

require "helper"
require "fluent/test/driver/parser"
require "fluent/plugin/parser_jq"

class JqParserTest < Test::Unit::TestCase
  setup do
    Fluent::Test.setup
  end

  teardown do
    @driver.instance.shutdown if @driver
  end

  test "it should require jq" do
    assert_raise(Fluent::ConfigError) { create_driver '' }
  end

  test "it should raise error on invalid jq program" do
    e = assert_raise(Fluent::ConfigError) { create_driver 'jq blah' }
    assert_match(/compile error/, e.message)
  end

  test "it should work" do
    d = create_driver 'jq split(",") | reduce .[] as $item ({}; ($item | split(":")) as $pair | .[$pair[0]] = $pair[1])'
    text = "name:jq,type:parser,author:Gimi"
    expected_record = {"name" => "jq", "type" => "parser", "author" => "Gimi"}
    d.instance.parse(text) { |time, record|
      assert_equal expected_record, record
    }
    assert_nil d.instance.log.logs.find { |log| log =~ /\[error\]/ }
  end

  test "it should skip if it does not return a hash" do
    d = create_driver 'jq split(",")'
    text = "name:jq,type:parser,author:Gimi"
    expected_record = {"name": "jq", "type": "parser", "author": "Gimi"}
    d.instance.parse(text) { |time, record| assert false }
    assert d.instance.log.logs.any? { |log| log =~ /\[error\]/ }
  end

  private

  def create_driver(conf)
    @driver = Fluent::Test::Driver::Parser.new(Fluent::Plugin::JqParser).configure(conf).tap { |d| d.instance.start }
  end
end
