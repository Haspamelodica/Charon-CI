#!/bin/bash

# TODO only debugging
echo Just before Maven call
printenv
exec mvn compile exec:java
