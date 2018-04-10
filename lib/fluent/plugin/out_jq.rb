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
require 'fluent/plugin/jq_mixin'

module Fluent::Plugin
  class JqOutput < Output
    Fluent::Plugin.register_output('jq', self)
    helpers :event_emitter

    include JqMixin

    config_set_desc :jq, 'The jq filter used to transform the input. If the filter returns an array, each object in the array will be a new record.'

    desc 'The prefix to be removed from the input tag when outputting a new record.'
    config_param :remove_tag_prefix, :string, default: ''

    def multi_workers_ready?
      true
    end

    def process(tag, es)
      new_es = Fluent::MultiEventStream.new
      es.each do |time, record|
	begin
	  new_records = jq_transform tag: tag, time: time, record: record
	  new_records = [new_records] unless new_records.is_a?(Array)
	  new_records.each { |new_record| new_es.add time, new_record }
	rescue JqError
	  log.error "Process failed with #{@jq}#{log.on_debug {' on ' + MultiJson.dump(record)}}, error: #{$!.message}"
	end
      end

      new_tag = tag.sub(/^#{Regexp.escape(@remove_tag_prefix)}\./, '')
      router.emit_stream(new_tag, new_es)
    end
  end
end
