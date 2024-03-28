export ES_URL="https://localhost:9200"
export CURL_PARAMS="--cacert ./elasticsearch/ssl/es.crt -u elastic:${ELASTIC_ADMIN_PWD}"

response=$(curl $CURL_PARAMS $ES_URL)

until [ "$response" = "200" ]; do
    response=$(curl $CURL_PARAMS --write-out %{http_code} --silent --output /dev/null "$ES_URL")
    >&2 echo "Waiting for Elasticsearch..."
    sleep 1
done

# next wait for ES status to turn to Green
health="$(curl $CURL_PARAMS -fsSL "$ES_URL/_cat/health?h=status")"
health="$(echo "$health" | sed -E 's/^[[:space:]]+|[[:space:]]+$//g')" # trim whitespace (otherwise we'll have "green ")

until [ "$health" = 'green' ]; do
    health="$(curl $CURL_PARAMS -fsSL "$ES_URL/_cat/health?h=status")"
    health="$(echo "$health" | sed -E 's/^[[:space:]]+|[[:space:]]+$//g')" # trim whitespace (otherwise we'll have "green ")
    >&2 echo "Waiting for Elasticsearch..."
    sleep 2
done

>&2 echo "Elastic Search is up"
