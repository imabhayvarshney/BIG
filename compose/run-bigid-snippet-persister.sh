#!/usr/bin/env bash
source setenv.sh

## BigID Snippet Persister Required Parameters:
## set in setenv.sh file OR explicitly:

#export DATABASE_ENDPOINT=<url of postgres DB server>
#export POSTGRES_DB=<name of postgres DB>
#export POSTGRES_SCHEMA=<name of postgres schema>

## To support AWS secret manager authentication to postgres DB
#export DB_AUTH_METHOD=AWS_SECRET_MANAGER
#export AWS_POSTGRES_SECRET_ID=<change to secrete id>
## used role if the account managing the EC2 does not hold permission to access AWS secret manager
#export POSTGRES_ROLE_ARN=<change to role>

## To support username password authentication to postgres DB
#export DB_AUTH_METHOD=USERNAME_PASSWORD
#export POSTGRES_USERNAME=<change to DB user>
#export POSTGRES_PASSWORD=<change to DB password>

##  snippet-persister optional parameters
#export HIKARI_MAX_LIFETIME=90000
#export HIKARI_CONNECTION_TIMEOUT=30000
#export HIKARI_MAX_POOL_SIZE=10

docker-compose -f bigid-snippet-persister-compose.yml ${*:-up -d}
