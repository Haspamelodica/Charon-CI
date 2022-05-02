#!/bin/bash

cd tests && exec mvn -Dnet.haspamelodica.studentcodeseparator.communicationargs="-t 10000 fifo out /fifos/exToStud in /fifos/studToEx" test
