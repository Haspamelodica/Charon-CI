#!/bin/bash

echo "---Student side log start---"
echo "---Student side log start---" >&2

docker logs "$1"

echo "---Student side log end---"
echo "---Student side log end---" >&2
