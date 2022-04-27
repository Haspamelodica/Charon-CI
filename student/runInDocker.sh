#!/bin/bash

# TODO only debugging
echo Just before Maven call
export
mvn compile exec:java >/logs/out.log 2>/logs/err.log
