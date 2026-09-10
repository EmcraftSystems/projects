#!/bin/sh

if [ $# -lt 1 ]; then
    echo "Usage: playsound.sh <soundfile>"
    exit 0
fi

while true
do
    aplay -q $1
done

