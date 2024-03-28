#!/usr/bin/env bash

# ./upgrade_mongo.sh 6.0 bigid password

if [ "$#" -lt 3 ]; then
    echo "Usage: $0 <target_version> <mongo_user> <mongo_password>"
    exit 1
fi

TARGET_VERSION=$1
MONGO_USER=$2
MONGO_PWD=$3

# Validate the target version
if [[ ! $TARGET_VERSION =~ ^(4\.4|5\.0|6\.0|7\.0)$ ]]; then
    echo "Error: Invalid target version. Please use 4.4, 5.0, 6.0, or 7.0."
    exit 1
fi

# Stop the existing MongoDB container
echo "Stopping the existing MongoDB container..."
docker stop bigid-mongo
STOP_STATUS=$?

if [ $STOP_STATUS -eq 0 ]; then
    echo "MongoDB container stopped successfully"
else
    echo -e "\x1B[31m*** Failed to stop MongoDB container!!! ***\e[0m"
    exit 1
fi

# Remove the existing MongoDB container
echo "Removing the existing MongoDB container..."
docker rm bigid-mongo
REMOVE_STATUS=$?

if [ $REMOVE_STATUS -eq 0 ]; then
    echo "MongoDB container removed successfully"
else
    echo -e "\x1B[31m*** Failed to remove MongoDB container!!! ***\e[0m"
    exit 1
fi

echo "Updating to MongoDB $TARGET_VERSION version starts ..."

echo "Running MongoDB $TARGET_VERSION"
docker run -d -p 27017:27017 -v bigid-mongo-data:/data/db --name bigid-mongo mongo:$TARGET_VERSION --replSet bigid-replica-set
sleep 10

COUNTER=0
while [ $COUNTER -lt 10 ]; do
    let COUNTER=COUNTER+1
    MONGOCONN=$(netstat -an | grep 27017)
    MONGOCONNSTAT=$(echo $?)
    MONGOTEST=$(docker exec -d bigid-mongo mongosh test)
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
    elif [ $COUNTER -eq "10" ]; then
        echo -e "\x1B[31m*** There is no connectivity to bigid-mongo!!! ***\e[0m"
        exit 1
    else
        echo "Waiting 6s for MongoDB container to start..."
        sleep 6
    fi
done

docker exec bigid-mongo mongosh admin --eval "printjson(db.adminCommand({setFeatureCompatibilityVersion:'$TARGET_VERSION'}));"

COUNTER=0
while [ $COUNTER -lt 10 ]; do
    echo "Waiting 10s for MongoDB container to start..."
    sleep 10
    docker exec bigid-mongo mongosh -u $MONGO_USER -p $MONGO_PWD --authenticationDatabase admin admin --eval "printjson(db.adminCommand( { getParameter: 1, featureCompatibilityVersion: 1 } ));"
    FEATURE_COMPATIBILITY_VERSION_MONGO_STATUS=$(echo $?)

    if [[ "$FEATURE_COMPATIBILITY_VERSION_MONGO_STATUS" -eq "0" ]]; then
        echo "featureCompatibilityVersion completed"
        break
    else
        echo "Waiting 6s for MongoDB container to start..."
        sleep 10
    fi
done

docker stop bigid-mongo
echo "Stop MongoDB container status: $(echo $?)"
docker rm bigid-mongo
echo "Remove MongoDB container status: $(echo $?)"

echo "Update to MongoDB $TARGET_VERSION version done"
