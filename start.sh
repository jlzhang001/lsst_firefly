#!/bin/sh

# DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# Absolute path to this script, e.g. /home/user/bin/foo.sh
SCRIPT=$(readlink -f "$0")
# Absolute path this script is in, thus /home/user/bin
DIR=$(dirname "$SCRIPT")
echo $DIR

IMAGE=victorren/ff_server:latest

if docker info; then
    docker pull $IMAGE
    docker rm firefly || echo "first time to run"
    docker run -p $1-$(($1+10)):8080-8090 \
        --name firefly\
        -v $DIR/frontend:/www/static \
        -v $DIR/backend:/www/algorithm \
        $IMAGE &
    PORT=ifconfig | egrep "^[a-z]|inet " | sed -e "s/ [ ]*Link.*/@/" -e "s/.*inet addr://" -e "s/ .*/#/" | tr -d '\012' | tr '@' ' ' | tr '#' '\012' | grep -e eth1 | awk '{ print $2 }'
    echo visit the web with the following address "$PORT":$1/static/index.html

else
    echo "Please ssh into docker-machine"
fi

