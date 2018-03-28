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

require "fluent/plugin/parser"

module Fluent
  module Plugin
    class JqParser < Fluent::Plugin::Parser
      Fluent::Plugin.register_parser("jq", self)

      desc 'The jq filter used to format the input. The result of the filter must return an object.'
      config_param :jq, :string

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

      def parse(text)
	record = [].tap { |buf|
	  @jq_filter.update(MultiJson.dump(text), false) { |r|
	    buf << MultiJson.load("[#{r}]").first
	  }
	}.first
	if record.is_a?(Hash)
	  yield parse_time(record), record
	else
	  log.error "jq filter #{@jq} did not return a hash, skip this record."
	end
      rescue JQ::Error
	log.error "Failed to parse #{text} with #{@jq}, error: #{$!.message}"
	nil
      end
    end
  end
end
