#!/bin/bash
# Make sure only non root users can run our script
if [[ $EUID -eq 0 ]]; then
   echo "This script must be run as non root user" 1>&2
   exit 1
fi

set +e

#Setup user enviroment to match server runtime enviroment
sudo groupadd www-data
sudo usermod -aG www-data $USER
sudo chown -R $USER:www-data .
sudo chmod -R g+rwx .

#Setup docker dependencies
ln -sf .env.docker .env

#Build docker images and run
docker-compose up --build
