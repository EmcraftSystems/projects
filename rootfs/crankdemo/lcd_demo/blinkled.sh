#!/bin/sh


blink() {
    echo 1 > /sys/class/leds/$1/brightness
    usleep 100000
    echo 0 > /sys/class/leds/$1/brightness
}


run() {

    while true
    do
	blink $1
        rate=`expr $2 \* 1000`
	usleep $rate
    done
}

if [ $# -lt 2 ]; then
    echo "Usage: blinkled.sh <DS1|DS2> <interval in ms>"
    exit 0
fi
    
run $1 $2
