#!/bin/bash

cd tests && exec gradle -Dnet.haspamelodica.charon.communicationargs="fifos /fifos/ /fifos/control true" test --info
