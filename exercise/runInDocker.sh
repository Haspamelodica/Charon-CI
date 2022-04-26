#!/bin/bash

# TODO make this less ugly and configurable
cd tests && mvn -Dstudentcodeseparator="-t 10000 fifo out /fifos/exToStud in /fifos/studToEx" test
