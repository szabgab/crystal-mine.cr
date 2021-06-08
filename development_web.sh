#!/usr/bin/bash

# This file is used by the docker-compose.override.yml (if the example is used)
shards install --ignore-crystal-version
mkdir -p bin
crystal build --release lib/sentry/src/sentry_cli.cr -o ./bin/sentry-docker
./bin/sentry-docker -b "crystal build src/webapp.cr -o bin/webapp" -r bin/webapp
