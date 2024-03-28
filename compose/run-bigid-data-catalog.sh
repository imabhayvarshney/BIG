#!/usr/bin/env bash
source setenv.sh
docker-compose -f bigid-data-catalog-compose.yml ${*:-up -d}
