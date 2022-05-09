#!/bin/bash

exec docker build -t charon:student -f student.Dockerfile .
