#!/usr/bin/env bash
echo "Initializing BigID scanner volume"
set -e
source setenv.sh
docker volume create --name bigid-scanner-data
docker run -d -v bigid-scanner-data:/etc/scanner --name bigid-scanner bigid/bigid-scanner${BIGID_ENV}
sleep 10

docker exec -i bigid-scanner sudo chown -R bigid:bigid /etc/scanner
docker stop bigid-scanner
docker rm bigid-scanner
