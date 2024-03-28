#!/usr/bin/env bash
source setenv.sh

docker-compose -f bigid-redis-compose.yml ${*:-up -d}
