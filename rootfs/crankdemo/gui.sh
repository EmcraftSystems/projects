#!/bin/sh

BASEDIR=$(dirname "$0")

$BASEDIR/uclinux-stm32f7-armle-fbdev-obj/bin/sbengine $BASEDIR/lcd_demo/lcd_demo.gapp &
#sleep 2
#$BASEDIR/crankapi/crankapi $BASEDIR/lcd_demo/sample.wav &
