#!/bin/sh

ifconfig lo 127.0.0.1

if [ -n "$ip" ]; then
    IP=`cat /proc/cmdline | sed -e "s/.*ip=//; s/:.*//"`
    SERVER=`cat /proc/cmdline | sed -e "s/.*ip=[^:]*://; s/:.*//"`
    GW=`cat /proc/cmdline | sed -e "s/.*ip=[^:]*:[^:]*://; s/:.*//"`
    NETMASK=`cat /proc/cmdline | sed -e "s/.*ip=[^:]*:[^:]*:[^:]*://; s/:.*//"`
    HOSTNAME=`cat /proc/cmdline | sed -e "s/.*ip=[^:]*:[^:]*:[^:]*:[^:]*://; s/:.*//"`
    IFACE=`cat /proc/cmdline | sed -e "s/.*ip=[^:]*:[^:]*:[^:]*:[^:]*:[^:]*://; s/:.*//"`
fi
if [ -n "$IFACE" -a -n "$IP" ]; then
    if [ -n "$NETMASK" ]; then
	ifconfig $IFACE $IP netmask $NETMASK
    else
	ifconfig $IFACE $IP
    fi
fi

if [ -n "$GW" ]; then
    route add default gw $GW
fi
