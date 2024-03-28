#!/usr/bin/env bash
source setenv.sh
docker-compose -f bigid-mongo-ssl-compose.yml ${*:-up -d}
