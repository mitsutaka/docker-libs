#!/bin/sh

while true; do
    mbsync "$@"
    echo "sleeping..."
    sleep 300
done
