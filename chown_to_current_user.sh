#!/bin/bash

export HOST_UID=$(id -u)
export HOST_GID=$(id -g)

exec docker run -u 0 -v $(readlink -f $1):/data studentcodeseparator:exercise chown -R $HOST_UID:$HOST_GID /data
