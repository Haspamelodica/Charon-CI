#!/bin/bash

# No timeout: The test may take a long time to initialize.
# Also, the environment must be able to kill the student container
# even if the test side never connects and the student container freezes,
# because a student could mimick this maliciously.
exec mvn -Dnet.haspamelodica.charon.communicationargs="fifos /fifos/ /fifos/control false" exec:java
