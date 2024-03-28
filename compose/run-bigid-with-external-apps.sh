#!/usr/bin/env bash
source setenv.sh

if [[ ${TELEMETRY_ENABLED} = "false" ]] || [ -z "${TELEMETRY_ENABLED}" ] ;then
    docker-compose -f bigid-ext-mongo-compose.yml -f bigid-autodiscovery-apps.yml -f bigid-classifier-helper.yml ${*:-up -d}
else
    if [ -n "${MONITORING_CUSTOMER_NAME}" ];then
        docker-compose -f bigid-ext-mongo-compose.yml -f bigid-autodiscovery-apps.yml -f bigid-classifer-helper.yml -f bigid-newrelic-compose.yml ${*:-up -d}
    else
        echo "Warning! MONITORING_CUSTOMER_NAME value is missing in setenv.sh file. Please supply a valid company name to complete BigID installation. If you would like to disable the telemetry, set TELEMETRY_ENABLED to false in setenv.sh."
        exit 1
    fi
fi
