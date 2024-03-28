#!/usr/bin/env bash
echo "Initializing BigID MongoDB"
set -e
docker run -d -p 27017:27017 -v bigid-mongo-data:/data/db --add-host bigid-mongo:127.0.0.1 --name bigid-mongo mongo:5.0 mongod --replSet bigid-replica-set --bind_ip_all
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
MONGO_DNS_NAME=${1:-bigid-mongo}
docker cp ./mongo/replica-set.key bigid-mongo:/data/db/replica-set.key
docker exec bigid-mongo sh -c 'chmod 400 /data/db/replica-set.key'
set +e
docker exec bigid-mongo mongo admin --eval "printjson(rs.initiate({ _id : 'bigid-replica-set',members: [{'_id': 0,'host': '$MONGO_DNS_NAME:27017','priority': 1}]}));"
sleep 2
docker stop bigid-mongo
docker rm bigid-mongo
