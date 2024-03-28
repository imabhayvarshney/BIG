#!/usr/bin/env bash
source setenv.sh
## BigID correlator required parameters (for remote correlator):
# export BIGID_CORR_CACHE_SIZE=<change to max cache size in GB example: export BIGID_CORR_CACHE_SIZE=16>
# export BIGID_MONGO_HOST_EXT=<change to BigID mongo host ip>
# export BIGID_MQ_HOST_EXT=<change to BigID mq host ip>
# export BIGID_UI_HOST_EXT=<change to BigID main api host ip>
## BigID Correlator Optional Parameters:
# export GENERATE_IDENTITIES_ON_START_UP=false
# export BIGID_MONGO_USER=<change to mongo user name>
# export BIGID_MONGO_PWD=<change to mongo user password>
# export CONFIGURATION_SERVICE_HOST_EXT=<change to config service main api host ip>

docker-compose -f bigid-new-correlation-compose.yml ${*:-up -d}
