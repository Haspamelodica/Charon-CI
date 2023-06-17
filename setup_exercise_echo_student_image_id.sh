#!/bin/bash

# "Parse" mode argument
mode="$1"

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
#TODO maybe just chown? We have to fix owner afterwards anyway,
# and when chowning we don't break permissions if they are meaningful
if [ "$mode" == "maven" ]; then
	mkdir -p     exercise/tests/target >/dev/null
	chmod -R a+w exercise/tests/target >/dev/null
elif [ "$mode" == "gradle" ]; then
	mkdir -R -p  exercise/tests/.gradle >/dev/null
	chmod a+w    exercise/tests/.gradle >/dev/null
	mkdir -R -p  exercise/tests/build >/dev/null
	chmod a+w    exercise/tests/build >/dev/null
else
	echo "Unknown mode: $mode"
	exit 1
fi

# Student container
cd student >/dev/null
exec ./build_container_echo_id.sh
