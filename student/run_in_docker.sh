#!/bin/bash

# TODO only debugging
echo Some standard output to real log
echo Some error output to real log >&2
exec mvn compile exec:java
