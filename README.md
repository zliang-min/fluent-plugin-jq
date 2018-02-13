# fluent-plugin-jq [![Build Status](https://travis-ci.org/Gimi/fluent-plugin-jq.svg?branch=master)](https://travis-ci.org/Gimi/fluent-plugin-jq)

[Fluentd](https://fluentd.org/) formatter plugin to format events with [jq](https://stedolan.github.io/jq/).

## Installation

Before you install this plugin, please make sure that `libjq` has been installed on your machine. For example, in alpine linux, debian, and ubuntu, you can install `libjq` by installing the `libjq-dev` package.

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

### jq_program (string) (required)

The jq program used to format income events. The result of the program should only return one item of any kind (a string, an array, an object, etc.). If it returns multiple items, only the first will be used.

### on_error (enum) (optional)

Defines the behavior on error happens when formatting an event. "skip" will skip the event; "ignore" will ignore the error and return the JSON representation of the original event; "raise_error" will raise a RuntimeError.

Available values: skip, ignore, raise_error

Default value: `ignore`.

### Example

```
<format>
  @type jq
  jq_program .message
  on_error raise_error
</format>
```

You can run

```
$ rake build_example
$ rake run_example
```

to build an example docker image, and run it to see how it works. You can run `$ rake rm_example` to delete the image afterward.

## Copyright

* Copyright(c) 2018- Zhimin (Gimi) Liang (https://github.com/Gimi)
* License
  * Apache License, Version 2.0
