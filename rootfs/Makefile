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

include ../Rules.make
