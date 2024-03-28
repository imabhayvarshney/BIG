# copy ssl certificates from local folder to BigID
docker cp cert.pem bigid-ui:/usr/share/nginx/html/server/cert.pem
docker cp key.pem bigid-ui:/usr/share/nginx/html/server/key.pem
docker restart bigid-ui
