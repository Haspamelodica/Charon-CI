#!/bin/bash

# TODO only debugging
echo Just before Maven call
printenv
echo "MAVEN_CONFIG: $MAVEN_CONFIG"
# TODO make this less ugly and configurable
cd tests && exec mvn -Dstudentcodeseparator="-t 10000 fifo out /fifos/exToStud in /fifos/studToEx" test
