#!/bin/bash

export HOST_UID=$(id -u)
export HOST_GID=$(id -g)

# TODO find better way to execute as root; or at least use scratch image.
exec docker run \
		--user 0 \
		--volume $(readlink -f $1):/data \
		--rm \
		ghcr.io/haspamelodica/charon:student \
		chown -R $HOST_UID:$HOST_GID /data
