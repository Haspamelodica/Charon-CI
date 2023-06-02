#!/bin/bash

if mvn compile; then
	# No timeout: The test may take a long time to initialize.
	# Also, the environment must be able to kill the student container
	# even if the test side never connects and the student container freezes,
	# because a student could mimick this maliciously.
	exec mvn -Dnet.haspamelodica.charon.communicationargs="fifo in /fifos/exToStud out /fifos/studToEx" exec:java
else
	# Open the reading end so the exercise side succeeds in opening both FIFOs
	cat /fifos/exToStud > /dev/null &
	# Echo the marker for "compilation error"
	echo -n "c" > /fifos/studToEx
fi
