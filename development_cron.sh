#!/usr/bin/bash

# This file is used by the docker-compose.override.yml (if the example is used)
shards install --ignore-crystal-version
tail -f /opt/shard.yml  # just to have something to wait on

