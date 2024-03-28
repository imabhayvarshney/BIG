#!/usr/bin/env bash
source setenv.sh
HOTSPOTS_COMPOSE_FILE=""
if [[ ${HOTSPOTS_ENABLED} = "true" ]];then
  echo "Hotspots is enabled"
  HOTSPOTS_COMPOSE_FILE="-f bigid-hotspots-compose.yml"
fi
if [[ ${TELEMETRY_ENABLED} = "false" ]] || [ -z "${TELEMETRY_ENABLED}" ] ;then
    docker-compose -f bigid-all-compose.yml -f bigid-ner-compose.yml -f bigid-clustering-compose.yml "${HOTSPOTS_COMPOSE_FILE}" ${*:-up -d}
else
    if [ -n "${MONITORING_CUSTOMER_NAME}" ];then
        docker-compose -f bigid-all-compose.yml -f bigid-ner-compose.yml -f bigid-clustering-compose.yml -f bigid-newrelic-compose.yml "${HOTSPOTS_COMPOSE_FILE}"  ${*:-up -d}
    else
        echo "Warning! MONITORING_CUSTOMER_NAME value is missing in setenv.sh file. Please supply a valid company name to complete BigID installation. If you would like to disable the telemetry, set TELEMETRY_ENABLED to false in setenv.sh."
        exit 1
    fi
fi
