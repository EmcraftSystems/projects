SAMPLE		:= rootfs
CUSTOM_APPS	:= lcdtest mpu kmod evtest

ifeq ($(MCU), $(filter $(MCU), IMXRT102X_NXPEVK IMXRT105X_NXPEVK IMXRT106X_NXPEVK IMXRT117X_NXPEVK MAAXBOARD_RT))
DTS_SUBDIR	:= nxp/imx/
endif

ifeq ($(MCU), $(filter $(MCU), IMXRT105X_NXPEVK IMXRT106X_NXPEVK IMXRT117X_NXPEVK MAAXBOARD_RT))
CUSTOM_APPS += lvgl
endif

# Uncomment the line below if you want to generate a tarball containing the root file system.
# This tarball can be used in scenario booting Linux with the root filesystem on SD card.
# FS_IMAGES	:= $(SAMPLE).tar.gz
#
# Uncommenting that line is NOT sufficient on its own. It only adds a tarball to
# the build; nothing else in the build keys off it. Two further steps are needed,
# and skipping either leaves a board that looks configured and is not:
#
# 1. Drop the built-in initramfs. By default these boards build a kernel with
#    CONFIG_INITRAMFS_SOURCE set (see <MCU>_defconfig) and rootfs.initramfs
#    creates /init, so the kernel runs /init and never evaluates root= at all.
#    Leave it in place and the board boots the built-in filesystem and ignores
#    the SD card -- silently, with no error to tell you why the rootfs you get
#    is not the one you built.
#
# 2. Set the kernel command line. For these boards it lives in the U-Boot
#    environment saved on the card, not in this tree -- the board's -sdcard
#    defconfig sets CONFIG_ENV_IS_IN_MMC=y so it can be written at the prompt:
#
#        setenv bootargs "${bootargs} root=/dev/mmcblk0p2 rw rootwait=30"
#        saveenv
#
#    rootwait is the part that is easy to miss and expensive to omit. Without it
#    the root device is evaluated before the asynchronous uSDHC probe has
#    registered mmcblk0. The kernel prints
#
#        VFS: Cannot open root device "/dev/mmcblk0p2" or unknown-block(0,0): error -6
#
#    then panics with "VFS: Unable to mount root fs" and reboots. Measured on an
#    i.MX RT1170-EVKB, 2026-08-26: two panics and three boot attempts before the
#    board came up, costing ~40 s on every reset.
#
#    Prefer the bounded rootwait=<seconds> form over bare rootwait. Bare rootwait
#    waits forever, which turns a missing or corrupt rootfs into a silent hang
#    instead of a panic -- the worse failure on a board whose only channel is a
#    serial console. The bounded form waits, then panics, and says so.

include ../Rules.make
