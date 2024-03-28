#!/usr/bin/env bash
set -e

echo "Initializing BigID Elasticsearch"

# See elasticsearch documentation:
# https://www.elastic.co/guide/en/elasticsearch/reference/7.15/security-api-put-user.html
# https://www.elastic.co/guide/en/elasticsearch/reference/current/built-in-roles.html

source setenv.sh

DEFAULT_PASSWD="Bigid111!"

if [[ ${ELASTIC_ADMIN_PWD} = ${DEFAULT_PASSWD} ]] || [[ ${BIGID_ELASTICSEARCH_PWD} = ${DEFAULT_PASSWD} ]]; then
  echo "WARNING! Please change the default passwords, env vars: ELASTIC_ADMIN_PWD, BIGID_ELASTICSEARCH_PWD"
fi

echo "Creating Elasticsearch SSL certificates volume"
docker-compose -f bigid-elasticsearch-create-certs.yml run --rm create_certs

echo "Starting bigid-elasticsearch service"
docker-compose -f bigid-elasticsearch-ssl.yml ${*:-up -d}

# Create the directory if it doesn't exist
mkdir -p "${ES_LOCAL_CRT_PATH}"

# Ensure that the directory is readable by the bigid user
chmod 755 "${ES_LOCAL_CRT_PATH}"

# Copy the certificate from bigid-elasticsearch to the local directory
docker cp "bigid-elasticsearch:${ES_CERTS_DIR}/ca/ca.crt" "${ES_LOCAL_CRT_PATH}/es.crt"

echo "Certificate copied from bigid-elasticsearch:${ES_CERTS_DIR}/ca/ca.crt to ${ES_LOCAL_CRT_PATH}/es.crt"

./wait-for-bigid-elasticsearch.sh

echo "Creating bigid user"
curl --cacert "${ES_LOCAL_CRT_PATH}/es.crt" -u "elastic:${ELASTIC_ADMIN_PWD}" -X POST "https://localhost:9200/_security/user/bigid?pretty" -H \
'Content-Type: application/json' -d " \
{ \
  \"password\" : \"${BIGID_ELASTICSEARCH_PWD}\", \
  \"roles\" : [ \"superuser\" ], \
  \"full_name\" : \"bigid\" \
}"
