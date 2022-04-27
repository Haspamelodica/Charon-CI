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

# Tests target folder incl. permissions
mkdir -p exercise/tests/target
chmod a+w exercise/tests/target

# Student container
cd student
./build_container.sh
