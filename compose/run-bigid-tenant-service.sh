#!/usr/bin/env bash
source setenv.sh

docker-compose -f bigid-tenant-service-compose.yml ${*:-up -d}
