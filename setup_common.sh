#!/bin/bash

# Exit on first error
set -e

# Fifos for communication
mkdir -p fifos
cd fifos 
rm -f     studToEx exToStud
mkfifo    studToEx exToStud
chmod a+w studToEx exToStud
