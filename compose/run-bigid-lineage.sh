#!/usr/bin/env bash
source setenv.sh
if [ -n "${BIGID_MONGO_SSL}" ] && [ "${BIGID_MONGO_SSL}" = "true" ] ;then
  docker-compose -f bigid-lineage-compose.yml -f bigid-lineage-ssl-volume-compose.yml -f bigid-ext-mongo-ssl-lineage-volume-compose.yml  ${*:-up -d}
else
  docker-compose -f bigid-lineage-compose.yml  ${*:-up -d}
fi
