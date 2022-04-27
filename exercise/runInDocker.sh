#!/bin/bash

# TODO only debugging
echo Just before Maven call
# TODO make this less ugly and configurable
cd tests && mvn -Dstudentcodeseparator="-t 10000 fifo out /fifos/exToStud in /fifos/studToEx" test
