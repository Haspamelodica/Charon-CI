#!/bin/bash

echo Just before Maven call
export
# TODO is the compile goal neccessary?
mvn exec:java >/logs/out.log 2>/logs/err.log
