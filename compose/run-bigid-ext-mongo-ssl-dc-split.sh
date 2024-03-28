#!/usr/bin/env bash
source setenv.sh
if [[ ${TELEMETRY_ENABLED} = "false" ]] || [ -z "${TELEMETRY_ENABLED}" ] ;then
    docker-compose -f bigid-ext-mongo-compose.yml -f bigid-ext-mongo-ssl-volume-compose.yml -f bigid-data-catalog-app-compose.yml\
     -f bigid-ner-compose.yml -f bigid-clustering-compose.yml -f bigid-ext-clustering-compose.yml\
      -f bigid-ext-mongo-ssl-clustering-compose.yml -f bigid-data-catalog-consumer-compose.yml -f bigid-ext-data-catalog-consumer-compose.yml\
      -f bigid-ext-mongo-ssl-data-catalog-consumer-compose.yml -f bigid-metadata-search-compose.yml -f bigid-metadata-search-ssl-volume-compose.yml\
        -f bigid-ext-mongo-ssl-mdsearch-volume-compose.yml ${*:-up -d}
else
    if [ -n "${MONITORING_CUSTOMER_NAME}" ] ;then
      docker-compose -f bigid-ext-mongo-compose.yml -f bigid-ext-mongo-ssl-volume-compose.yml -f bigid-data-catalog-app-compose.yml\
       -f bigid-ner-compose.yml -f bigid-clustering-compose.yml -f bigid-ext-clustering-compose.yml\
        -f bigid-ext-mongo-ssl-clustering-compose.yml -f bigid-data-catalog-consumer-compose.yml -f bigid-ext-data-catalog-consumer-compose.yml\
        -f bigid-ext-mongo-ssl-data-catalog-consumer-compose.yml -f bigid-metadata-search-compose.yml -f bigid-metadata-search-ssl-volume-compose.yml\
          -f bigid-ext-mongo-ssl-mdsearch-volume-compose.yml -f bigid-newrelic-compose.yml ${*:-up -d}
    else
        echo "Warning! MONITORING_CUSTOMER_NAME value is missing in setenv.sh file. Please supply a valid company name to complete BigID installation. If you would like to disable the telemetry, set TELEMETRY_ENABLED to false in setenv.sh."
        exit 1
    fi
fi
