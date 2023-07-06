#!/bin/bash

cd tests && exec mvn -Dnet.haspamelodica.charon.communicationargs="fifo out /fifos/exToStud in /fifos/studToEx" test
