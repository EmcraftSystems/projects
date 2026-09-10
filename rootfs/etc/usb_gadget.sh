#!/bin/sh

#
# Vendor = Linux Foundation
#
VENDOR_ID="0x1d6b"

#
# Product = Multifunction Composite Gadget
#
PRODUCT_ID="0x0104"
SERIAL_NUM="01"
MANUFACTURER_STR="Emcraft"
LANG="0x409"
PRODUCT_STR="USB composite gadget example"
MASS_STORAGE_NAME="mass_storage"
MASS_STORAGE_NUMBER="0"
NETWORK_NAME="rndis"
NETWORK_NUMBER="0"
CONFIG_NAME="c"
CONFIG_NUMBER="1"
GADGET_NAME="g1"

usage() {
    echo "`basename $0` [-m] [-r] [-d] [-p <usb port>]"
    echo "where:"
    echo "'m' option - configure mass storage gadget"
    echo "'r' option - configure rndis gadget"
    echo "'p' option - USB port number"
    echo "'d' option - deactivate USB composite gadget"
}

error() {
    echo "USB Gadget configure error $1"
    exit -1
}

deactivate_gadgets() {
    if [ ! -d "${GADGET_NAME}" ]; then
        echo "USB composite gadgets are not configured"
        exit 0
    fi

    cd ${GADGET_NAME}/ || error 3
    rm -f configs/${CONFIG_NAME}.${CONFIG_NUMBER}/${MASS_STORAGE_NAME}.${MASS_STORAGE_NUMBER}
    rm -f configs/${CONFIG_NAME}.${CONFIG_NUMBER}/${NETWORK_NAME}.${NETWORK_NUMBER}
    rmdir configs/${CONFIG_NAME}.${CONFIG_NUMBER}/strings/${LANG}
    rmdir configs/${CONFIG_NAME}.${CONFIG_NUMBER}
    [ -d functions/${NETWORK_NAME}.${NETWORK_NUMBER} ] && rmdir functions/${NETWORK_NAME}.${NETWORK_NUMBER}
    [ -d functions/${MASS_STORAGE_NAME}.${MASS_STORAGE_NUMBER} ] && rmdir functions/${MASS_STORAGE_NAME}.${MASS_STORAGE_NUMBER}
    rmdir strings/${LANG}
    cd ..
    rmdir ${GADGET_NAME}
    echo "USB gadgets deactivated"
    exit 0
}

#
# Process options
#
usb_port=0
while getopts ":hdmrp:" opt
do
    case "$opt" in
        h) usage ; exit 0 ;;
        d) deactivate="yes" ;;
        p) usb_port=$OPTARG ;;
        m) mass_storage="yes" ;;
        r) rndis="yes" ;;
        *) echo "`basename $0`: Invalid option '$OPTARG'" >&2 ; exit -1 ;;
        esac
done
shift `expr $OPTIND - 1`

#
# Determ USB OTG available ports
#
usb_nport=0
udc=$(ls /sys/class/udc)
for num in `echo $udc | sed 's/ /\n/g'`; do
    eval udc_num$usb_nport=\"$num\"
    usb_nport=$((usb_nport+1))
done

eval ctrl="\$udc_num$usb_port"
if [ -z $ctrl ]; then
    echo "The USB port #$usb_port is not configured in OTG"
    exit -1
fi

cat /proc/mounts | grep configfs > /dev/null || mount -t configfs none /sys/kernel/config/
cd /sys/kernel/config/usb_gadget || error 1

if [ "$deactivate" = "yes" ]; then
    deactivate_gadgets
    echo "USB gadgets deactivated"
    exit 0
fi

#
# Configure USB gadget via configfs
#
if [ -z $mass_storage ] && [ -z $rndis ]; then
    echo "No gadgets are defined for configuring"
    exit 0
fi

if [ -d "${GADGET_NAME}" ]; then
    echo "USB composite gadgets are already configured"
    exit 0
fi

mkdir ${GADGET_NAME} || error 2
cd ${GADGET_NAME}/ || error 3

#
# Add description for a device
#
echo ${VENDOR_ID} > idVendor || error 4
echo ${PRODUCT_ID} > idProduct || error 5
mkdir strings/${LANG} || error 6
echo ${SERIAL_NUM} > strings/${LANG}/serialnumber || error 7
echo ${MANUFACTURER_STR} > strings/${LANG}/manufacturer || error 8
echo ${PRODUCT_STR} > strings/${LANG}/product || error 9

#
# Create configuration for the composite device
#
mkdir configs/${CONFIG_NAME}.${CONFIG_NUMBER} || error 10
mkdir configs/${CONFIG_NAME}.${CONFIG_NUMBER}/strings/${LANG} || error 11
echo "composite" > configs/${CONFIG_NAME}.${CONFIG_NUMBER}/strings/${LANG}/configuration || error 12
echo 120 > configs/${CONFIG_NAME}.${CONFIG_NUMBER}/MaxPower || error 13

#
# Define the mass storage function
#
if [ "$mass_storage" = "yes" ]; then
    mkdir functions/${MASS_STORAGE_NAME}.${MASS_STORAGE_NUMBER} || error 14
    ln -s functions/${MASS_STORAGE_NAME}.${MASS_STORAGE_NUMBER} configs/${CONFIG_NAME}.${CONFIG_NUMBER} || error 15
    echo /dev/mmcblk0 > functions/${MASS_STORAGE_NAME}.${MASS_STORAGE_NUMBER}/lun.0/file || error 16
fi

#
# Define the Ethernet Gadget (RNDIS) function
#
if [ "$rndis" = "yes" ]; then
    mkdir functions/${NETWORK_NAME}.${NETWORK_NUMBER} || error 17
    ln -s functions/${NETWORK_NAME}.${NETWORK_NUMBER} configs/${CONFIG_NAME}.${CONFIG_NUMBER} || error 18
fi

echo $ctrl > UDC || error 20

echo "USB Gadet config done"
exit 0
