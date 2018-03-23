# frozen_string_literal: true

# Copyright 2018- Zhimin (Gimi) Liang (https://github.com/Gimi)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'fluent/plugin/output'

module Fluent::Plugin
  class JqOutput < Output
    Fluent::Plugin.register_output('jq', self)
    helpers :event_emitter

    desc 'The jq filter used to transform the input. The result of the filter should return an object.'
    config_param :jq, :string

    desc 'The prefix to be removed from the input tag when outputting a new record.'
    config_param :remove_tag_prefix, :string, default: ''

    def initialize
      super
      require "jq"
    end

    def configure(conf)
      super
      @jq_filter = JQ::Core.new @jq
    rescue JQ::Error
      raise Fluent::ConfigError, "Could not parse jq filter: #{@jq}, error: #{$!.message}"
    end

    def multi_workers_ready?
      true
    end

    def process(tag, es)
      new_es = Fluent::MultiEventStream.new
      es.each do |time, record|
	begin
	  @jq_filter.update(MultiJson.dump(tag: tag, time: time, record: record), false) { |r|
	    # the filter could return an array
	    new_records = [MultiJson.load("[#{r}]").first]
	    new_records.flatten!
	    new_records.each { |new_record| new_es.add time, new_record }
	  }
	rescue JQ::Error
	  log.error "Failed to transform #{MultiJson.dump record} with #{@jq}, error: #{$!.message}"
	end
      end

      new_tag = tag.sub(/^#{Regexp.escape(@remove_tag_prefix)}\./, '')
      router.emit_stream(new_tag, new_es)
    end
  end
end
