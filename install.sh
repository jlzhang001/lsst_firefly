#! /bin/sh
IMAGE=victorren/ff_server
if docker info; then
    docker pull $IMAGE
else
    echo "Fail to pull docker image. Start docker first."
fi
