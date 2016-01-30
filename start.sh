#!/bin/sh

# DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# Absolute path to this script, e.g. /home/user/bin/foo.sh
SCRIPT=$(readlink -f "$0")
# Absolute path this script is in, thus /home/user/bin
DIR=$(dirname "$SCRIPT")
echo $DIR

if docker info; then
    docker pull victorren/firefly_lsst
    docker rm firefly || echo "first time to run"
    docker run -p $1-$(($1+10)):8080-8090 \
        --name firefly\
        -v $DIR/frontend:/www/static \
        -v $DIR/backend:/www/algorithm \
        victorren/firefly_lsst&
    docker exec firefly bash startup.sh
else
    echo "Please ssh into docker-machine"
fi

