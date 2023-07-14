#!/bin/bash

# Exit on first error
set -e

# Fifos for communication
mkdir -p fifos
(
	cd fifos
	rm -f     control
	mkfifo    control
	chmod a+w control
	# This is neccessary so the Docker containers can create their own fifos
	chmod a+w .
)

if [ "$STUDENT_SIDE_SOURCES" != "" ]; then
	rm -rf student/src_from_exercise
	cp -r exercise/tests/"$STUDENT_SIDE_SOURCES" student/src_from_exercise
fi
	