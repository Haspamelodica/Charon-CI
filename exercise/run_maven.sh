#!/bin/bash

cd tests && exec mvn -Dnet.haspamelodica.charon.communicationargs="fifos /fifos/ /fifos/control true" test
