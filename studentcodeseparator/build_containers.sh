#!/bin/bash

# The base container Dockerfile copies source files. So it needs access to the build context.
docker build -t studentcodeseparator:base -f base.Dockerfile .

# The exercise and student-base containers Dockerfiles only compile sources already in the containers, so they don't need a build context.
docker build -t studentcodeseparator:exercise - < exercise.Dockerfile
docker build -t studentcodeseparator:student-base - < student-base.Dockerfile
