#!/bin/sh

source ./scripts/commands.sh


set -o errexit

write_primary "Building environment"

write_line "Copying your id_rsa key"
cp ~/.ssh/id_rsa id_rsa

remove_containers gta-web
remove_containers econ/gta-api

cp ~/.ssh/id_rsa id_rsa

write_primary "Building econ/gta-api"
docker build --file=vm/Dockerfile -t econ/gta-api .

write_line "Removing your id_rsa key"
rm id_rsa


write_primary "Data volume"

write_line "Removing data volume"
remove_containers "gta-api-data"
write_line "Creating data volume"
docker run -v /var/gta-api/data-volume --name gta-api-data centos:centos6 /bin/true

# MongoDB
remove_containers gta-mongodb

write_primary "Running MongoDB"
docker run -i --name gta-mongodb -d mongo:2.6 --smallfiles

write_line "Creating database users"
addMongoUsers

write_primary "Starting environment"

write_line  "Running the container"
docker run -d \
    --add-host=gta-test.economist.com:127.0.0.1 \
    --add-host=gta-dev.economist.com:127.0.0.1 \
    --name gta-web \
    --link gta-mongodb:db \
    --volumes-from gta-api-data \
    -v $(pwd):/var/www/gta-api \
    -p 85:80 \
    econ/gta-api


write_line "Removing directories from data volume"
docker exec gta-web rm -rf  \
    /var/gta-api/data-volume/logs \
    /var/gta-api/data-volume/cache


write_line "Removing directories from the app"
docker exec gta-web rm -rf  \
    /var/www/gta-api/app/cache \
    /var/www/gta-api/app/logs

write_line "Creating directories"
docker exec gta-web mkdir \
    /var/gta-api/data-volume/logs \
    /var/gta-api/data-volume/cache \
    /var/gta-api/data-volume/cache/hydrators \
    /var/gta-api/data-volume/cache/proxies

write_line "Setting permissions"
docker exec gta-web chmod -R 777 \
    /var/gta-api/data-volume/logs \
    /var/gta-api/data-volume/cache

write_line "Create symlink for cache"
docker exec gta-web ln -s /var/gta-api/data-volume/cache /var/www/gta-api/app/cache

write_line "Create symlink for logs"
docker exec gta-web ln -s /var/gta-api/data-volume/logs  /var/www/gta-api/app/logs

cp scripts/hooks/docker-pre-commit .git/hooks/pre-commit
chmod a+x .git/hooks/pre-commit

linked_containers="$(docker ps | grep gta-web |  awk '{print $1}')"

if [ -n "$linked_containers" ]; then
    write_success " 🍷  Environment created! Get coding."
else
    write_error "Environment not created"
    exit 1
fi

write_primary "-----------------------------------------"
write_primary "Make commands"
make help
write_primary "-----------------------------------------"

exit 0
