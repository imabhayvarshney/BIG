#!/usr/bin/env bash
source setenv.sh
## BigID Scanner Required Parameters (for remote scanner):
## set in setenv.sh file OR explicitly:
# export BIGID_UI_PORT_EXT=9090
## BigID Scanner Optional Parameters:
# export SCANNER_HOST_NAME=BigID Scanner 1
# export SCANNER_GROUP_NAME=scanner1

if [[ ${NER_HTTP_PROXY} != "" ]] || [[ ${NER_HTTPS_PROXY} != "" ]];then
  echo "Proxy is enabled for remote ner"
  docker-compose -f bigid-scanner-with-hadoop-compose.yml -f bigid-ner-hadoop-compose.yml -f bigid-ner-hadoop-remote-compose.yml -f bigid-ner-hadoop-remote-proxy-compose.yml ${*:-up -d}
else
  docker-compose -f bigid-scanner-with-hadoop-compose.yml -f bigid-ner-hadoop-compose.yml -f bigid-ner-hadoop-remote-compose.yml ${*:-up -d}
fi
