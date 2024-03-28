#!/usr/bin/env bash
source setenv.sh
# Metadata Search Elastic Search Config

if [ -z "${BIGID_ELASTICSEARCH_EXTERNAL_FULL_URL}" ] ;then
    echo "Starting bigid-elasticsearch & bigid-metadata-search"
    if [ -n "${BIGID_MONGO_SSL}" ] && [ "${BIGID_MONGO_SSL}" = "true" ] ;then
      docker-compose -f bigid-elasticsearch-ssl.yml -f bigid-metadata-search-compose.yml -f bigid-metadata-search-ssl-volume-compose.yml -f bigid-ext-mongo-ssl-mdsearch-volume-compose.yml ${*:-up -d}
    else
      docker-compose -f bigid-elasticsearch-ssl.yml -f bigid-metadata-search-compose.yml -f bigid-metadata-search-ssl-volume-compose.yml ${*:-up -d}
    fi
else
    echo "Starting bigid-metadata-search, elasticsearch URL: ${BIGID_ELASTICSEARCH_EXTERNAL_FULL_URL}"
    if [ -n "${BIGID_MONGO_SSL}" ] && [ "${BIGID_MONGO_SSL}" = "true" ] ;then
      docker-compose -f bigid-metadata-search-compose.yml -f bigid-metadata-search-ssl-volume-compose.yml -f bigid-ext-mongo-ssl-mdsearch-volume-compose.yml ${*:-up -d}
    else
      docker-compose -f bigid-metadata-search-compose.yml -f bigid-metadata-search-ssl-volume-compose.yml ${*:-up -d}
    fi
fi
