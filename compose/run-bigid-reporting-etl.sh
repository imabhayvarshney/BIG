#!/usr/bin/env bash
source setenv.sh

docker-compose -f bigid-reporting-etl-compose.yml ${*:-up -d}
