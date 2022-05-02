#!/bin/bash

export HOST_UID=$(id -u)
export HOST_GID=$(id -g)

# TODO find better way to execute as root; or at least use scratch image.
exec docker run -u 0 -v $(readlink -f $1):/data ghcr.io/haspamelodica/studentcodeseparator-for-ci:base chown -R $HOST_UID:$HOST_GID /data
