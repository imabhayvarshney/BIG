#!/usr/bin/env bash
source setenv.sh
docker-compose -f bigid-ol-vsam-api-compose.yml ${*:-up -d}
