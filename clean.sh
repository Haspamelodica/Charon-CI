#!/bin/bash

# Exercise ownership is fixed after the exercise container is run,
# but in case something failed it helps to fix ownership again.
./fix_exercise_ownership.sh

rm -rf student/assignment exercise/tests fifos
