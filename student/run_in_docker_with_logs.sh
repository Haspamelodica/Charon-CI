#!/bin/bash

echo Some error output >&2
exec mvn compile exec:java
