#!/bin/bash

cd tests && exec gradle -Dnet.haspamelodica.charon.communicationargs="fifo out /fifos/exToStud in /fifos/studToEx" test --info
