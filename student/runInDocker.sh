#!/bin/bash

# TODO is the compile goal neccessary?
mvn compile exec:java >/logs/out.log 2>/logs/err.log
