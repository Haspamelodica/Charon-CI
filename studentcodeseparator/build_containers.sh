#!/bin/bash

# Exit on first error
set -e

# The base container Dockerfile copies source files. So it needs access to the build context.
docker build -t ghcr.io/haspamelodica/studentcodeseparator-for-ci:base -f base.Dockerfile .

# The exercise and student-base containers Dockerfiles only compile sources already in the containers, so they don't need a build context.
docker build -t ghcr.io/haspamelodica/studentcodeseparator-for-ci:exercise - < exercise.Dockerfile
docker build -t ghcr.io/haspamelodica/studentcodeseparator-for-ci:student-base - < student-base.Dockerfile
