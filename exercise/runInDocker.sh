#!/bin/bash

cd tests &&
mvn -Dstudentcodeseparator="-t 10000 fifo out /fifos/exToStud in /fifos/studToEx" test
