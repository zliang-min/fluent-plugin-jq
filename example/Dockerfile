FROM fluent/fluentd:v1.1.0
LABEL maintainer="Zhimin (Gimi) Liang (https://github.com/Gimi)"

COPY . /tmp/fluent-plugin-jq/

RUN apk update \
 && apk add --no-cache jq-dev \
 && apk add --no-cache --virtual .build-deps \
        build-base \
        git \
	ruby-dev \
 && cd /tmp/fluent-plugin-jq \
 && gem build fluent-plugin-jq.gemspec \
 && gem install *.gem \
 && apk del .build-deps \
 && rm -rf /var/cache/apk/* \
 && cp /tmp/fluent-plugin-jq/example/fluent.conf /fluentd/etc/ \
 && cp /tmp/fluent-plugin-jq/example/statsd.sample / \
 && rm -rf /tmp/* /var/tmp/* /usr/lib/ruby/gems/*/cache/*.gem
