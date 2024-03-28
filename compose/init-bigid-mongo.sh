#!/usr/bin/env bash

export MONGODB_VERSION=${MONGODB_VERSION:=6.0}
# Get mongo credentials
MONGO_USER=${1:-bigid}
MONGO_PWD=${2:-password}
MONGO_MONITOR_USER=${3:-monitor}
MONGO_MONITOR_PWD=${4:-password}
MONGO_DNS_NAME=${5:-bigid-mongo}
MONGO_CLIENT=$([[ $MONGODB_VERSION == "6.0" ]] && echo 'mongosh' || echo 'mongo')
echo "Initializing BigID MongoDB , MONGODB_VERSION: $MONGODB_VERSION, MONGO_USER: $MONGO_USER, MONGO_MONITOR_USER: $MONGO_MONITOR_USER, MONGO_DNS_NAME: $MONGO_DNS_NAME"
set -e
docker volume create --name bigid-mongo-data
docker run -d -p 27017:27017 -v bigid-mongo-data:/data/db --add-host bigid-mongo:127.0.0.1 --name bigid-mongo mongo:$MONGODB_VERSION mongod --replSet bigid-replica-set --bind_ip_all

attempt=0
while [ $attempt -le 59 ]; do
    attempt=$(( $attempt + 1 ))
    echo "Waiting for server to be up (attempt: $attempt)..."
    result=$(docker logs bigid-mongo)
    if grep -q 'Waiting for connections' <<< $result ; then
      echo "Mongodb is up!"
      break
    fi
    sleep 2
done

docker exec bigid-mongo $MONGO_CLIENT admin --eval "printjson(rs.initiate({ _id : 'bigid-replica-set',members: [{'_id': 0,'host': '$MONGO_DNS_NAME:27017','priority': 1}]}));"
echo "Running bigid-mongo health check..."
COUNTER=0
   while [  $COUNTER -lt 10 ]; do
            let COUNTER=COUNTER+1
            docker exec bigid-mongo $MONGO_CLIENT  admin --eval "printjson(db.stats())" > /dev/null;
            RESULT=$?
            if [ $RESULT -ne 0 ]; then
                echo "mongodb not running"
                sleep 6
            else
                echo "mongodb running!"
                break
            fi
done

docker cp ./mongo/replica-set.key bigid-mongo:/data/db/replica-set.key
docker exec bigid-mongo sh -c 'chmod 400 /data/db/replica-set.key'
set +e
sleep 2
docker exec bigid-mongo $MONGO_CLIENT admin --eval "printjson(rs.conf())"
docker exec bigid-mongo $MONGO_CLIENT admin --eval "printjson(db.adminCommand({setFeatureCompatibilityVersion:'$MONGODB_VERSION'}));"
docker exec bigid-mongo $MONGO_CLIENT admin --eval "printjson(db.createUser({user:'$MONGO_USER',pwd:'$MONGO_PWD',roles:['root']}));"
docker exec bigid-mongo $MONGO_CLIENT admin --eval "printjson(db.createRole({role:'listCollections',privileges:[{resource: {db:'',collection:''}, actions: ['listCollections']}], roles: [] }));"
docker exec bigid-mongo $MONGO_CLIENT admin --eval "printjson(db.createUser({user:'$MONGO_MONITOR_USER',pwd:'$MONGO_MONITOR_PWD',roles:['clusterMonitor', 'listCollections']}));"
set -e
docker cp ./mongo/ssl/bigidmongo.pem bigid-mongo:/data/db/bigidmongo.pem
docker stop bigid-mongo
docker rm bigid-mongo
