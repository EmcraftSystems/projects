SAMPLE		:= rootfs_flash

RFS_BUILD_DIR	:= rootfs-build-tmpdir

FS_IMAGES	:= $(SAMPLE).initramfs

ifeq ($(MCU), $(filter $(MCU), IMXRT105X_NXPEVK IMXRT106X_NXPEVK))
DTS_SUBDIR      := nxp/imx/

#FLASHFS_TYPE	:= ubi
FLASHFS_TYPE	:= jffs2

ifeq ($(FLASHFS_TYPE),ubi)
MKFSUBIFS_FLAGS	:= -U -m 8 -e 65408 -c 41 -R 64KiB
UBINIZE_FLAGS	:= -m 64 -p 64KiB
endif

SEPARATE_DTB	:= no
endif

ifeq ($(MCU),IMXRT117X_NXPEVK)
DTS_SUBDIR      := nxp/imx/

#FLASHFS_TYPE  := ubi
FLASHFS_TYPE   := jffs2

ifeq ($(FLASHFS_TYPE),ubi)
MKFSUBIFS_FLAGS        := -U -m 8 -e 65408 -c 89 -R 64KiB
UBINIZE_FLAGS  := -m 64 -p 64KiB
endif

SEPARATE_DTB   := no
endif

ifeq ($(MCU),MAAXBOARD_RT)
DTS_SUBDIR      := nxp/imx/

#FLASHFS_TYPE	:= ubi
FLASHFS_TYPE	:= jffs2

ifeq ($(FLASHFS_TYPE),ubi)
MKFSUBIFS_FLAGS	:= -U -m 1 -e 262016 -c 72 -R 256KiB
UBINIZE_FLAGS	:= -m 1 -p 256KiB
endif

SEPARATE_DTB	:= no
endif

include ../Rules.make
