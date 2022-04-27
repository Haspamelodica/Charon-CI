#!/bin/bash

exec ./run_in_docker_with_logs.sh | tee /logs/out.log 1>&3 2>&1 | tee /logs/err.log 1>&2 3>&1
