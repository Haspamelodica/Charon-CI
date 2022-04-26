#!/bin/bash

# Exit on first error
set -e

# Fifos for communication
mkdir fifos
mkfifo fifos/studToEx fifos/exToStud
chmod a+w fifos/studToEx fifos/exToStud

# Student log files
mkdir studentLogs
touch studentLogs/out.log studentLogs/err.log
chmod a+w studentLogs/out.log studentLogs/err.log

# Tests target folder incl. permissions
mkdir exercise/tests/target
chmod a+w exercise/tests/target

# Student container
cd student
exec ./build_container.sh
