#!/bin/bash

# TODO only debugging
echo Just before Maven call
export
exec mvn compile exec:java
