#!/bin/bash

cd tests && exec mvn -Dnet.haspamelodica.charon.communicationargs="-t 10000 fifo out /fifos/exToStud in /fifos/studToEx" test
