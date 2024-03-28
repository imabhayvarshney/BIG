#!/usr/bin/env bash
echo "Initializing BigID MongoDB"
set -e
docker volume create --name bigid-mongo-data
docker run -d -p 27017:27017 -v bigid-mongo-data:/data/db --name bigid-mongo mongo:5.0
sleep 10
echo "Running bigid-mongo health check..."
COUNTER=0
   while [  $COUNTER -lt 10 ]; do
            let COUNTER=COUNTER+1
            MONGOCONN=$(nc -zv localhost 27017)
            MONGOCONNSTAT=$(echo $?)
            MONGOTEST=$(docker exec -d bigid-mongo mongo test)
            MONGOTESTSTAT=$(echo $?)
        if [[ "$MONGOCONNSTAT" -eq "0" ]]; then
            echo "There is connectivity to bigid-mongo container"
            echo $MONGOCONN
        else
            echo "Waiting 6s for connectivity..."
            sleep 6
        fi
        if [[ "$MONGOTESTSTAT" -eq "0" ]]; then
            echo "A test connection was successfully established to MongoDB"
            echo $MONGOTEST
            break
        elif [  $COUNTER -eq "10" ]; then
            echo -e "\x1B[31m*** There is no connectivity to bigid-mongo!!! ***\e[0m"
            exit 1
        else
            echo "Waiting 6s for MongoDB container to start..."
            sleep 6
        fi
done
# Get mongo credentials
MONGO_USER=${1:-bigid}
MONGO_PWD=${2:-password}
MONGO_MONITOR_USER=${3:-monitor}
MONGO_MONITOR_PWD=${4:-password}
set +e
docker exec bigid-mongo mongo admin --eval "printjson(db.adminCommand({setFeatureCompatibilityVersion:'5.0'}));"
docker exec bigid-mongo mongo admin --eval "printjson(db.createUser({user:'$MONGO_USER',pwd:'$MONGO_PWD',roles:['root']}));"
docker exec bigid-mongo mongo admin --eval "printjson(db.createRole({role:'listCollections',privileges:[{resource: {db:'',collection:''}, actions: ['listCollections']}], roles: [] }));"
docker exec bigid-mongo mongo admin --eval "printjson(db.createUser({user:'$MONGO_MONITOR_USER',pwd:'$MONGO_MONITOR_PWD',roles:['clusterMonitor', 'listCollections']}));"
set -e
docker cp ./mongo/ssl/bigidmongo.pem bigid-mongo:/data/db/bigidmongo.pem
docker stop bigid-mongo
docker rm bigid-mongo
