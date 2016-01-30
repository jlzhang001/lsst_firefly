#!/bin/bash

if docker info; then
    docker pull victorren/firefly_lsst:baseimg
    docker rm firefly || echo "first time to run"
    docker run -p -name firefly $1+$(($1+10)):8080:8090 victorren/firefly_lsst:baseimg &
    docker exec firefly ./startup.sh
else
    echo "Please ssh into docker-machine"
fi

