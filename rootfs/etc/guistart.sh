#!/bin/sh

# Mount USB Flash
# MOUNTPOINT="/mnt/usbflash"
#for tmp in `seq 1 10`; do
#    mount -t vfat /dev/sda1 ${MOUNTPOINT} 2> /dev/null
#    if [ $? != 0 ]; then
#	usleep 50000
#    else
#	break
#    fi
#done

MOUNTPOINT="/mnt/flash"
mount -t jffs2  /dev/mtdblock5  ${MOUNTPOINT}

[ -f ${MOUNTPOINT}/gui.sh ] && sh ${MOUNTPOINT}/gui.sh
