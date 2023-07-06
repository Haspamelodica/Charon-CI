#!/bin/bash

# Exit on first error
set -e

for i in "$@"; do
	#TODO maybe just chown? We have to fix owner afterwards anyway,
	# and when chowning we don't break permissions if they are meaningful
	mkdir -p     exercise/tests/"$i"
	chmod -R a+w exercise/tests/"$i"
done
