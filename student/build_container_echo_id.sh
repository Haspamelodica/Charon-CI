#!/bin/bash

#TODO maybe don't build an image, but use "docker cp"?
exec docker build -q -f student.Dockerfile .
