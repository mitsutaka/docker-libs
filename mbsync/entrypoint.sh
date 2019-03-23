#!/bin/sh

while true; do
    mbsync $@
    echo "sleeping..."
    sleep $(expr 60 \* 5)
done
