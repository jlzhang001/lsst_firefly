#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if docker info; then
    docker pull victorren/firefly_lsst:baseimg
    docker rm firefly || echo "first time to run"
    docker run -p $1+$(($1+10)):8080:8090 \
        -name firefly\
        -v $DIR/frontend:/www/static\
        -v $DIR/backend:/www/algorithm\
        victorren/firefly_lsst:baseimg &
    docker exec firefly ./startup.sh
else
    echo "Please ssh into docker-machine"
fi

