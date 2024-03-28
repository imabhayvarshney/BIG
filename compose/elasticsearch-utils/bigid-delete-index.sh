#!/usr/bin/env bash
set -e
export ES_URL=$1                    # e.g "https://bigid-elasticsearch:9200"
export ES_CERT_PATH=$2              # e.g ./elasticsearch/ssl/es.crt
export BIGID_ELASTICSEARCH_PWD=$3
export BIGID_TENANT_ID=$4

export CURL_PARAMS="--cacert ${ES_CERT_PATH} -u bigid:${BIGID_ELASTICSEARCH_PWD}"

echo "Running: curl $CURL_PARAMS -X DELETE $ES_URL/${BIGID_TENANT_ID}"
curl $CURL_PARAMS -X DELETE $ES_URL/${BIGID_TENANT_ID}
