#!/bin/bash

# Exercise folder may contain files from Docker user
./chown_to_current_user.sh exercise

rm -rf studentLogs student exercise fifos
