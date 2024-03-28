#!/usr/bin/env bash

source setenv.sh
## BigID Scanner Required Parameters (for the remote scanner):
## set in setenv.sh file OR explicitly:
# export BIGID_UI_PORT_EXT=9090
## BigID Scanner Optional Parameters:
# export SCANNER_HOST_NAME='BigID Scanner 1'
# export SCANNER_GROUP_NAME='scanner1'

if [[ ${NER_HTTP_PROXY} != "" ]] || [[ ${NER_HTTPS_PROXY} != "" ]];then
  echo "The proxy settings has been enabled for the remote NER."
  docker-compose -f bigid-scanner-compose.yml -f bigid-ner-compose.yml -f bigid-ner-remote-compose.yml -f bigid-ner-remote-proxy-compose.yml ${*:-up -d}
else
  docker-compose -f bigid-scanner-compose.yml -f bigid-ner-compose.yml -f bigid-ner-remote-compose.yml ${*:-up -d}
fi
