#!/bin/bash

# TODO only debugging
echo Some standard output to real log
echo Some error output to real log >&2
exec ./run_in_docker_with_logs.sh >/logs/out.log 2>/logs/err.log
