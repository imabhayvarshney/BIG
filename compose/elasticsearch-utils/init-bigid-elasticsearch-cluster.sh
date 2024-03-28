#!/usr/bin/env bash
echo "Initializing BigID Elasticsearch"
set -e
export ES_DATA_DIR=/data/elasticsearch
export ES_ETC_CONF_DIR=/etc/conf/elasticsearch
export NODES_NUM=3

echo "Creating ${ES_DATA_DIR}"
mkdir -p ${ES_DATA_DIR}
chmod g+rwx ${ES_DATA_DIR}
sudo chgrp 0 ${ES_DATA_DIR}
sudo chown -R 1000:1000 ${ES_DATA_DIR}

echo "Creating ${ES_ETC_CONF_DIR}"
mkdir -p ${ES_ETC_CONF_DIR}
chmod g+rwx ${ES_ETC_CONF_DIR}
sudo chgrp 0 ${ES_ETC_CONF_DIR}


#The vm.max_map_count setting should be set permanently in /etc/sysctl.conf:
#grep vm.max_map_count /etc/sysctl.conf
#vm.max_map_count=262144
sysctl -w vm.max_map_count=262144

echo "Creating docker volumes for data nodes, NODES_NUM=${NODES_NUM}"
for i in $(seq 1 ${NODES_NUM});
do
  if [ ! -d "${ES_DATA_DIR}/es${i}" ]; then
    echo "Creating volume es${i}_vol in ${ES_DATA_DIR}/es${i}"
    mkdir ${ES_DATA_DIR}/es${i}
    sudo docker volume create --name es${i}_vol --opt type=none --opt device=${ES_DATA_DIR}/es${i} --opt o=bind;
  else
    echo "volume es${i}_vol exists in ${ES_DATA_DIR}/es${i}"
  fi
done


cat << EOF > ${ES_ETC_CONF_DIR}/elasticsearch.yml
cluster.name: "docker-cluster"
network.host: 0.0.0.0
indices.queries.cache.size: 30%
indices.fielddata.cache.size: 40%
EOF

# configure SSL
# https://www.elastic.co/guide/en/elasticsearch/reference/current/configuring-tls-docker.html

#bin/elasticsearch-users useradd mdsearch -p Bigid111!
#cat /etc/conf/elasticsearch/users
#mdsearch:$2a$10$hYLHHWHVenFea0o4OXNZF.7LEO5VveZ3diX1vf.oKjF0ezNZ5TtxG



#https://www.elastic.co/guide/en/elasticsearch/reference/current/docker.html
#Always bind data volumes
#You should use a volume bound on /usr/share/elasticsearch/data for the following reasons:
#
#1. The data of your Elasticsearch node won’t be lost if the container is killed
#2. Elasticsearch is I/O sensitive and the Docker storage driver is not ideal for fast I/O
#3. It allows the use of advanced Docker volume plugins

# logging
#Consider centralizing your logs by using a different logging driver.
#Also note that the default json-file logging driver is not ideally suited for production use.
# https://docs.docker.com/config/containers/logging/configure/

# security
# ip filtering: https://www.elastic.co/guide/en/elasticsearch/reference/current/ip-filtering.html
# https://www.elastic.co/guide/en/elasticsearch/reference/current/configuring-stack-security.html


# left to do:
