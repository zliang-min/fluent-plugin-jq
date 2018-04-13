require 'shellwords'
require 'multi_json'

module JqMixin
  JqError = Class.new(RuntimeError)

  def self.included(plugin)
    plugin.config_param :jq, :string
  end

  def configure(conf)
    super
    p = start_process(null_input: true)
    err = p.read
    raise Fluent::ConfigError, "Could not parse jq filter: #{@jq}, error: #{err}" if err =~ /compile error/m
  rescue
    raise Fluent::ConfigError, "Could not parse jq filter: #{@jq}, error: #{$!.message}"
  ensure
    p.close if p # if `super` fails, `p` will be `nil`
  end

  def start
    super
    @jq_process = start_process
    @lock = Thread::Mutex.new
  end

  def shutdown
    @jq_process.close rescue nil
    super
  end

  def start_process(filter: @jq, null_input: false)
    IO.popen(%Q"jq #{'-n' if null_input} --unbuffered -c '#{filter}' 2>&1", 'r+')
  end

  def jq_transform(object)
    result = @lock.synchronize do
      @jq_process.puts MultiJson.dump(object)
      @jq_process.gets
    end
    MultiJson.load result
  rescue MultiJson::ParseError
    raise JqError.new(result)
  rescue Errno::EPIPE
    @jq_process.close
    @jq_process = start_process
    retry
  end
end
