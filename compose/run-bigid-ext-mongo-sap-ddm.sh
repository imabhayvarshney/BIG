#!/usr/bin/env bash
source setenv.sh
export BIGID_PRODUCT_TYPE=ddm
## BigID required parameter for external MongoDB, set in setenv.sh file OR explicitly
#export BIGID_MONGO_HOST_EXT=10.0.0.1
#export MONGO_EXTERNAL_FULL_URL="mongodb://bigid:password@10.0.0.1:27017/bigid-server?authSource=admin"

if [[ ${TELEMETRY_ENABLED} = "false" ]] || [ -z "${TELEMETRY_ENABLED}" ] ;then
    docker-compose -f bigid-ext-mongo-compose.yml ${*:-up -d}
else
    if [ -n "${MONITORING_CUSTOMER_NAME}" ];then
        docker-compose -f bigid-ext-mongo-compose.yml -f bigid-newrelic-compose.yml ${*:-up -d}
    else
        echo "Warning! MONITORING_CUSTOMER_NAME value is missing in setenv.sh file. Please supply a valid company name to complete BigID installation. If you would like to disable the telemetry, set TELEMETRY_ENABLED to false in setenv.sh."
        exit 1
    fi
fi
