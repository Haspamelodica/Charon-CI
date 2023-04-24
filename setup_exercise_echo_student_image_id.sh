#!/bin/bash

# Exit on first error
set -e >/dev/null

# Fifos for communication
mkdir -p fifos >/dev/null
(
	cd fifos >/dev/null
	rm -f     studToEx exToStud >/dev/null
	mkfifo    studToEx exToStud >/dev/null
	chmod a+w studToEx exToStud >/dev/null
)

# Tests target folder incl. permissions
mkdir -p exercise/tests/target >/dev/null
chmod a+w exercise/tests/target >/dev/null

# Student container
cd student >/dev/null
exec ./build_container_echo_id.sh
