#!/usr/bin/env bash
source setenv.sh
export BIGID_ALL_HOST=192.168.65.2
export BIGID_MONGO_HOST_EXT=${BIGID_ALL_HOST}
export BIGID_MQ_HOST_EXT=${BIGID_ALL_HOST}
export BIGID_UI_HOST_EXT=${BIGID_ALL_HOST}

export BIGID_IGNITE_HOST_EXT=ignite-master

export GENERATE_IDENTITIES_LOCAL=false
export BIGID_CORR_CLIENT_MODE=true

#export BIGID_UI_PORT_EXT="9090"
#export SPRING_PROFILES_ACTIVE="test"
docker-compose -f bigid-ignite-correlator-compose.yml ${*:-up -d}
