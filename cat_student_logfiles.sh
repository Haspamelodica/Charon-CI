#!/bin/bash

echo '---Student side stdout log start---'
cat studentLogs/out.log
echo '---Student side stdout log end---'

# Make sure stdout log is flushed before stderr log starts.
# Not neccessary, but improves log readability.
sleep 1

echo '---Student side stderr log start---' >&2
cat studentLogs/err.log >&2
echo '---Student side stderr log end---' >&2
