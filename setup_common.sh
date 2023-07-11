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

if [ "$STUDENT_SIDE_SOURCES" != "" ]; then
	rm -rf student/src_from_exercise
	cp -r exercise/tests/"$STUDENT_SIDE_SOURCES" student/src_from_exercise
fi
	