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

require "fluent/plugin/formatter"
require "fluent/plugin/jq_mixin"

module Fluent
  module Plugin
    class JqFormatter < Fluent::Plugin::Formatter
      Fluent::Plugin.register_formatter("jq", self)

      include JqMixin

      config_set_desc :jq, 'The jq filter used to format income events. If the result returned from the filter is not a string, it will be encoded as a JSON string.'

      desc 'Defines the behavior on error happens when formatting an event. "skip" will skip the event; "ignore" will ignore the error and return the JSON representation of the original event; "raise_error" will raise a RuntimeError.'
      config_param :on_error, :enum, list: [:skip, :ignore, :raise_error], default: :ignore

      def initialize
	super
      end

      def format(tag, time, record)
	item = jq_transform record
	if item.instance_of?(String)
	  item
	else
	  MultiJson.dump item
	end
      rescue JqError
	msg = "Format failed with #{@jq}#{log.on_debug { ' on ' + MultiJson.dump(record) }}, error: #{$!.message}"
	log.error msg
	case @on_error
	when :skip
	  return ''
	when :ignore
	  return MultiJson.dump(record)
	when :raise_error
	  raise msg
	end
      end
    end
  end
end
