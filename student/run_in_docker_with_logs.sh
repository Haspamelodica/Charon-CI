#!/bin/bash

# TODO only debugging
echo Just before Maven call
printenv
echo "MAVEN_CONFIG: $MAVEN_CONFIG"
cat /usr/local/bin/mvn-entrypoint.sh
exec mvn compile exec:java
