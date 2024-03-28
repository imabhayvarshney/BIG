#!/usr/bin/env bash
source setenv.sh
if [[ ${TELEMETRY_ENABELD} = "false" ]] || [ -z "${TELEMETRY_ENABELD}" ] ;then
    docker-compose -f bigid-ext-mongo-compose.yml -f bigid-ner-compose.yml -f  bigid-clustering-compose.yml -f bigid-ext-clustering-compose.yml -f bigid-aci-compose.yml -f bigid-ext-aci-compose.yml -f bigid-labeler-compose.yml ${*:-up -d}
else
    if [ -n "${MONITORING_CUSTOMER_NAME}" ];then
        docker-compose -f bigid-ext-mongo-compose.yml -f bigid-ner-compose.yml -f  bigid-clustering-compose.yml -f bigid-ext-clustering-compose.yml -f bigid-aci-compose.yml -f bigid-ext-aci-compose.yml -f bigid-newrelic-compose.yml -f bigid-labeler-compose.yml ${*:-up -d}
    else
        echo "Warning! MONITORING_CUSTOMER_NAME value is missing in setenv.sh file. Please supply a valid company name to complete BigID installation. If you would like to disable the telemetry, set TELEMETRY to false in setenv.sh."
        exit 1
    fi
fi
