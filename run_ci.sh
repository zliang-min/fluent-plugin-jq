#!/bin/sh

apk add --no-cache build-base jq-dev \
  && bundle \
  && rake
