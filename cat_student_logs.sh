#!/bin/bash

echo "---Student side log start---"
# Make sure stdout has been flushed. Avoids reordering stderr output before the start message.
sleep 1

docker logs "$1"
# Make sure stderr has been flushed. Avoids reordering stderr output after the end message.
sleep 1
echo "---Student side log end---"
