#!/usr/bin/env bash

IMAGE=dotfiles
CONTAINER=$IMAGE-debug
VER=0
TAG="$IMAGE":"$VER"

docker rm -f "$CONTAINER"
docker image rm -f $TAG || true

gotodot

# build an image
# TODO:
# --no-cache can be removed to improve speed,
# but I must not commit it because sometimes
# docker caches bad responses. It will be removed
# after migration to rclone
docker build --no-cache --tag $TAG .

# create a container
docker run -it --name $CONTAINER $TAG
