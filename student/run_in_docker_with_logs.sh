#!/bin/bash

# TODO only debugging
echo Just before Maven call
printenv
echo "MAVEN_CONFIG: $MAVEN_CONFIG"
exec mvn compile exec:java
