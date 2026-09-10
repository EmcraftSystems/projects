#!/bin/sh

if [ $# -lt 1 ]; then
    echo "Usage: backlight.sh <value 0-100>"
    exit 0
fi

if [ ! -f /sys/class/backlight/backlight/max_brightness ]; then
    echo "Backlight is not supported"
    exit -1
fi

if [ $1 -eq "0" ]; then
    echo 0 > /sys/class/backlight/backlight/brightness
    exit 0
fi


max=`cat /sys/class/backlight/backlight/max_brightness`

val=`expr $1 \* $max / 100`

if [ $1 -gt "0" -a $val = "0" ]; then
    val="1"
fi

echo "Set brightness to $val of $max"
echo $val > /sys/class/backlight/backlight/brightness
