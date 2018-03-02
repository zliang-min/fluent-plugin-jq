# fluent-plugin-jq

[![Gem Version](https://badge.fury.io/rb/fluent-plugin-jq.svg)](https://badge.fury.io/rb/fluent-plugin-jq)
[![Build Status](https://travis-ci.org/Gimi/fluent-plugin-jq.svg?branch=master)](https://travis-ci.org/Gimi/fluent-plugin-jq)

A collection of [Fluentd](https://fluentd.org/) plugins use [jq](https://stedolan.github.io/jq/). It now contains two plugins:
* `jq` formatter - a formatter plugin formats inputs using jq filters.
* `jq_transformer` - a filter plugin transform inputs.

## Installation

See also: [Plugin Management](https://docs.fluentd.org/v1.0/articles/plugin-management).

Before you install this plugin, please make sure that `libjq` has been installed on your machine. For example, it's called `jq-dev` on alpine linux; while on debian, and ubuntu, you will find it as the `libjq-dev` package.

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

The jq filter for formatting income events. The result of the program should only return one item of any kind (a string, an array, an object, etc.). If it returns multiple items, only the first will be used.

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
