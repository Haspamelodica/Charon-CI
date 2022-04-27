#!/bin/bash

# Exit on first error
set -e

# Fifos for communication
mkdir -p fifos
(
	cd fifos
	rm -f     studToEx exToStud
	mkfifo    studToEx exToStud
	chmod a+w studToEx exToStud
)

# Student log files
mkdir -p student/logs
(
	cd student/logs
	touch     out.log err.log
	chmod a+w out.log err.log
)

# Tests target folder incl. permissions
mkdir -p exercise/tests/target
chmod a+w exercise/tests/target

# Student container
cd student
# TODO exec doesn't seem to work here
pwd
ls -lRA
# sleep so stdout is flushed
sleep 1
./build_container.sh
