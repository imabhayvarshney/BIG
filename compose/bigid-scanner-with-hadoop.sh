#!/usr/bin/env bash
source setenv.sh
docker-compose -f bigid-scanner-with-hadoop-compose.yml ${*:-up -d}
