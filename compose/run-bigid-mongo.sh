#!/usr/bin/env bash
source setenv.sh
docker-compose -f bigid-mongo-compose.yml ${*:-up -d}
