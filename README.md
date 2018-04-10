# fluent-plugin-jq

[![Gem Version](https://badge.fury.io/rb/fluent-plugin-jq.svg)](https://badge.fury.io/rb/fluent-plugin-jq)
[![Build Status](https://travis-ci.org/Gimi/fluent-plugin-jq.svg?branch=master)](https://travis-ci.org/Gimi/fluent-plugin-jq)

A collection of [Fluentd](https://fluentd.org/) plugins use [jq](https://stedolan.github.io/jq/). It now contains four plugins:
* `jq` formatter - a formatter plugin formats inputs using jq filters.
* `jq_transformer` - a filter plugin transform inputs.
* `jq` output - a output plugin uses jq filter to generate new events.
* `jq` parser - a parser plugin uses jq filter to parse inputs.

## Installation

See also: [Plugin Management](https://docs.fluentd.org/v1.0/articles/plugin-management).

Before you install this plugin, please make sure the `jq` command line tool has been installed on your machine. Plugins defined in this gem will call the `jq` command to make the transformation.

### RubyGems

```
$ gem install fluent-plugin-jq
```

### Bundler

Add following line to your Gemfile:

```ruby
gem "fluent-plugin-jq"
```

And then execute:

```
$ bundle
```

## Configuration

See also: [Output Plugin Overview](https://docs.fluentd.org/v1.0/articles/output-plugin-overview).

### `jq` Formatter

#### Example

```
<match **>
  @type stdout
  <format>
    @type jq
    jq '"\(.time | todate) [\(.logLevel | ascii_upcase)] \(.log)"'
  </format>
</match>
```

In the example above, it will format the input with the jq filter specified in the `jq` parameter before sendint it to stdout. For example, given an input like

```javascript
{"time": 1520030594, "logLevel": "info", "log": "this is an example."}
```

What will be printed in stdout is

```
2018-03-02T22:43:14Z [INFO] this is an example.
```

#### Parameters

##### @type (string) (required)

This must be `jq`.

##### jq (string) (required)

The jq filter for formatting income events. The returned result should be a string, if not, it will be encoded to a JSON representation in a string.

##### on_error (enum) (optional)

Defines the behavior on error happens when formatting an event. "skip" will skip the event; "ignore" will ignore the error and return the JSON representation of the original event; "raise_error" will raise a RuntimeError.

Available values: skip, ignore, raise_error

Default value: `ignore`.

### `jq_transformer` Filter

#### Example

```
<filter **>
  @type jq_transformer
  jq .record + {time, tag}
</filter>
```

The above example will transform the input event (the record) by adding two more fields: `time` (the event time from fluentd) and `tag` (the event tag), to it. For example, given an input event like:

```javascript
{"logLevel": "info", "log": "this is an example."}
```

with tag = `"some.tag"` and time = `1520030594`. Then the new event will like

```javascript
{"logLevel": "info", "log": "this is an example.", "time": 1520030594, "tag": "some.tag"}
```

#### Parameters

##### @type (string) (required)

This must be `jq_transformer`.

##### jq (string) (required)

The jq filter used to transform the input. The result of the filter should return an object. If after applying the transforming the new event is not an object (a hash), the event will be dropped.

### `jq` Output

#### Example

```
<match raw.data>
  @type jq
  jq .record | to_entries
  remove_tag_prefix raw
</filter>
```

The above example will generate one event for each key-value pair in each input, and then tag it with "data" ("raw." is removed), and send it back to router. For example, given an input like

```javascript
{"logLevel": "info", "log": "this is an example."}
```

It generates two new events:

```javascript
{"key": "logLevel", "value": "info"}
{"key": "log", "value": "this is an example."}
```

#### Parameters

##### @type (string) (required)

This must be `jq`.

##### jq (string) (required)

The jq filter used to generate new events. The result of the filter should return an object or an array of objects. New events will be put back to router so that they will be processed again.

##### remove_tag_prefix (string) (optional)

The prefix to remove from the input tag when outputting a new event. A prefix has to be a complete tag part.
Example: If `remove_tag_prefix` is set to 'foo', the input tag foo.bar.baz is transformed to bar.baz and the input tag 'foofoo.bar' is not modified.

Default value: `""`.

### `jq` Parser

#### Example

```
<source>
  @type tail
  tag tail.*
  path /some/path/*
  <parse>
    @type jq
    jq 'split(",") | reduce .[] as $item ({}; ($item | split(":")) as $pair | .[$pair[0]] = ($pair[1][:-2] | tonumber))'
  </parse>
</source>
```

Given inputs like

```
cpu.usage:10|g,cpu.free:90|g
memory.usage:100|g,memory.rss:80|g
```

It generates records:

```javascript
{"cpu.usage": 10, "cpu.free": 90}
{"memory.usage": 100, "memory.rss": 80}
```

#### Parameters

##### @type (string) (required)

This must be `jq`.

##### jq (string) (required)

The jq filter used to parse inputs. The result of the filter must return an object, otherwise the result will be dropped.

### Built-in Example

Once you clone the project from github, you can run the following commands to see a real example for the plugins.

```
$ rake build_example
$ rake run_example
```

The above commands will build the example to a docker image, and run it. You can run `$ rake rm_example` to delete the image afterward.

## Copyright

* Copyright(c) 2018- Zhimin (Gimi) Liang (https://github.com/Gimi)
* License
  * Apache License, Version 2.0
