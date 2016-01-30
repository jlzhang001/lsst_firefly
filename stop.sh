#!/bin/sh

if docker info; then
    docker exec firefly ./shutdown.sh &
    docker stop firefly
else
    echo "Please ssh into docker-machine"
fi

