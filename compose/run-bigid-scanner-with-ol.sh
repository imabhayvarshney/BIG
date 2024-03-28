#!/usr/bin/env bash
source setenv.sh
## BigID Scanner Required Parameters (for remote scanner):
## set in setenv.sh file OR explicitly:
# export BIGID_MQ_HOST_EXT=<change to BigID main mq host ip>
# export BIGID_UI_HOST_EXT=<change to BigID main api host ip>
## BigID Scanner Optional Parameters:
# export SCANNER_HOST_NAME=BigID Scanner 1
# export SCANNER_GROUP_NAME=scanner1

docker-compose -f bigid-scanner-compose.yml -f bigid-ol-vsam-api-compose.yml ${*:-up -d}
