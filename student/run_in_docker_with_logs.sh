#!/bin/bash

exec mvn compile exec:java
echo Some error output >&2
