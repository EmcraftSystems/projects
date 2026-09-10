#
# This file contains common make rules for all projects.
#

MAKE		:= make -j9

#
# Buildroot integration.
# BUILDROOT_DEFCONFIG is set by ACTIVATE.sh when the user passes a
# buildroot defconfig as the second positional arg; the toolchain and
# sysroot from buildroot/output_<defconfig>/ are then used instead of
# the prebuilt toolchain from tools/. Run "make buildroot" to build the
# toolchain, "make buildroot-menuconfig" to configure buildroot packages.
#
BUILDROOT_DIR	:= $(INSTALL_ROOT)/buildroot

ifdef BUILDROOT_DEFCONFIG
# Derive output directory name from defconfig (strip _defconfig suffix)
BUILDROOT_OUTPUT_NAME := output_$(patsubst %_defconfig,%,$(BUILDROOT_DEFCONFIG))
BUILDROOT_OUTPUT := $(BUILDROOT_DIR)/$(BUILDROOT_OUTPUT_NAME)
BUILDROOT_HOST	 := $(BUILDROOT_OUTPUT)/host
BUILDROOT_TC_BIN := $(BUILDROOT_HOST)/bin
BUILDROOT_SYSROOT:= $(BUILDROOT_HOST)/arm-buildroot-uclinuxfdpiceabi/sysroot
BUILDROOT_O	 := O=$(BUILDROOT_OUTPUT)

# Override toolchain paths to use Buildroot output
export CROSS_COMPILE_APPS := arm-buildroot-uclinuxfdpiceabi-
export PATH := $(BUILDROOT_TC_BIN):$(PATH)
export TOOLS_DIR := $(BUILDROOT_HOST)/arm-buildroot-uclinuxfdpiceabi
export TOOLS_LIBS := $(BUILDROOT_SYSROOT)
# Short aliases for use in .initramfs files
export BUILDROOT_DEFCONFIG
export BUILDROOT_TARGET := $(BUILDROOT_OUTPUT)/target
export TARGET_ROOT := $(BUILDROOT_OUTPUT)/target

# Sentinel file — if this doesn't exist, buildroot needs to be built
BUILDROOT_SENTINEL := $(BUILDROOT_TC_BIN)/$(CROSS_COMPILE_APPS)gcc
else
# Legacy mode: A2F/root is a frozen snapshot extracted from the full
# arm_cortexm_sdk_defconfig buildroot build, plus pre-built binaries from
# packages not yet migrated to buildroot (wpa_supplicant, ppp, bluetooth, ...).
# Layout, sonames, and ABI of the migrated portion match $(BUILDROOT_TARGET).
# Busybox is the one exception: its legacy build location is
# $(INSTALL_ROOT)/A2F/busybox/busybox, not under A2F/root/.
export TARGET_ROOT := $(INSTALL_ROOT)/A2F/root
export TOOLS_LIBS  := $(TARGET_ROOT)
endif

KERNEL_CONFIG	:= kernel$(if $(MCU),.$(MCU))
KERNEL_DEFCONFIG := $(if $(MCU),$(MCU))_defconfig
KERNEL_LD	:= lds$(if $(MCU),.$(MCU))
KERNEL_DTS	:= dts$(if $(MCU),.$(MCU))$(if $(BRD),.$(BRD))
KERNEL_BOOT	:= $(INSTALL_ROOT)/linux/arch/arm/boot
KERNEL_DTS_PATH	:= $(KERNEL_BOOT)/dts/$(DTS_SUBDIR)
RAMFS_CONFIG	:= initramfs
BUSYBOX_CONFIG	:= busybox
KERNEL_IMAGE	:= uImage
KERNEL_DTB	:= dtb
RFS_BUILD_DIR	:= rootfs-build-tmpdir

# Path to the kernel modules directory in context of which
# these loadable modules are built
KERNELDIR	:=  $(INSTALL_ROOT)/linux

CFLAGS		:= "-Os"
XIP_CFLAGS	:= "-Os -static -fPIC"
XIP_LDFLAGS	:= ""

ifeq ($(CROSS_COMPILE),arm-v7-linux-uclibceabi-)
KERNEL_CFLAGS	:= -mno-fdpic
endif

FS_IMAGES_OUTPUT := $(patsubst %.initramfs,%.$(FLASHFS_TYPE),$(FS_IMAGES))

# SDK selection stamp. Records which toolchain (legacy vs. a specific
# buildroot defconfig) was active for the previous build of this project.
# A mismatch on the next build means stale per-project artefacts compiled
# against a different sysroot — refuse to proceed and tell the user to
# clean. Cleared by "make clean".
SDK_STAMP	:= .sdk_stamp
SDK_STAMP_VALUE	:= $(if $(BUILDROOT_DEFCONFIG),buildroot:$(BUILDROOT_DEFCONFIG),legacy)

.PHONY	: all busybox linux kmenuconfig bmenuconfig clean kclean bclean aclean $(CUSTOM_APPS) $(XIP_CUSTOM_APPS) clone buildroot buildroot-menuconfig buildroot-clean buildroot-sdk _sdk_check

ifdef BUILDROOT_DEFCONFIG
all		: _sdk_check _buildroot_check _do_modules linux $(FS_IMAGES_OUTPUT)
else
all		: _sdk_check _do_modules linux $(FS_IMAGES_OUTPUT)
endif

_sdk_check	:
	@if [ -f $(SDK_STAMP) ]; then \
		_old=`cat $(SDK_STAMP)`; \
		if [ "$$_old" != "$(SDK_STAMP_VALUE)" ]; then \
			echo "ERROR: $(SAMPLE) was last built against SDK '$$_old'," >&2; \
			echo "       current activation selects   SDK '$(SDK_STAMP_VALUE)'." >&2; \
			echo "       Run 'make clean' before rebuilding." >&2; \
			exit 1; \
		fi; \
	fi
	@echo "$(SDK_STAMP_VALUE)" > $(SDK_STAMP)

# For those projects that have support for loadable kernel modules
# enabled in the kernel configuration, we need to build and install
# modules in the kernel tree, as a first step in building the project.
# This is needed to allow us building an external module (or several
# such modules) as an external module from a project subdirectory
# and then to include the resultant module object in the project
# initramfs filesystem.

MODULES_ON	:= $(shell grep CONFIG_MODULES=y $(SAMPLE).$(KERNEL_CONFIG) || grep CONFIG_MODULES=y $(KERNEL_DEFCONFIG))
INSTALL_MOD_PATH:= $(INSTALL_ROOT)/linux

ifeq ($(MODULES_ON),)
_do_modules	:
else
_do_modules	: _prepare_modules
endif

_prepare_modules: $(SAMPLE).$(KERNEL_CONFIG)
	cp -f $(INSTALL_ROOT)/linux/initramfs-list-min.stub \
		$(INSTALL_ROOT)/linux/initramfs-list-min
	rm -f $(INSTALL_ROOT)/linux/usr/initramfs_data.cpio \
		$(INSTALL_ROOT)/linux/usr/initramfs_data.cpio.gz
	cp -f $(SAMPLE).$(KERNEL_CONFIG) $(INSTALL_ROOT)/linux/.config
	cp -f $(INSTALL_ROOT)/linux/arch/arm/kernel/vmlinux.lds.S.good \
		$(INSTALL_ROOT)/linux/arch/arm/kernel/vmlinux.lds.S
	([ -e $(SAMPLE).$(KERNEL_LD) ] && \
		cp -f $(SAMPLE).$(KERNEL_LD) \
		$(INSTALL_ROOT)/linux/arch/arm/kernel/vmlinux.lds.S) || \
	true;
	KCFLAGS=$(KERNEL_CFLAGS) $(MAKE) -C $(INSTALL_ROOT)/linux vmlinux
	KCFLAGS=$(KERNEL_CFLAGS) $(MAKE) -C $(INSTALL_ROOT)/linux modules

linux		: $(SAMPLE).$(KERNEL_IMAGE)

$(CUSTOM_APPS)	:
	CFLAGS=${CFLAGS} LDFLAGS=${LDFLAGS} make -C $@ all

$(XIP_CUSTOM_APPS)	:
	CFLAGS=${XIP_CFLAGS} LDFLAGS=${XIP_LDFLAGS} make -C $@ all

$(RFS_BUILD_DIR): _do_modules $(SAMPLE).initramfs busybox $(CUSTOM_APPS)
	SAMPLE=$(SAMPLE) $(HOST_PYTHON_EXE_PATH) \
		../rfs-builder.py create-rfs-dir \
		$(SAMPLE).$(RAMFS_CONFIG) `pwd`/$(RFS_BUILD_DIR)

%.ubi: $(RFS_BUILD_DIR)
	mkfs.ubifs $(MKFSUBIFS_FLAGS) -F -r $(RFS_BUILD_DIR) \
		$(patsubst %.ubi,%.ubifs,$@)
	ubinize -o $@ $(UBINIZE_FLAGS) ubinize.cfg

%.jffs2: $(RFS_BUILD_DIR)
	mkfs.jffs2 -X lzo -x zlib -q -r $(RFS_BUILD_DIR) -o $(SAMPLE).jffs2

$(SAMPLE).tar.gz: $(RFS_BUILD_DIR)
	tar -C $(RFS_BUILD_DIR) -zcf $@ --owner=0 --group=0 .

clean		: kclean bclean aclean
	rm -rf $(SAMPLE).$(KERNEL_IMAGE) $(SAMPLE).$(KERNEL_DTB) \
		$(FS_IMAGES_OUTPUT) $(SAMPLE).ubifs \
		$(RFS_BUILD_DIR) $(SDK_STAMP)

kclean		:
	$(MAKE) -C $(INSTALL_ROOT)/linux clean

ifdef BUILDROOT_DEFCONFIG
bclean		:
	$(MAKE) -C $(BUILDROOT_DIR) $(BUILDROOT_O) busybox-dirclean
	rm -f $(BUILDROOT_BB_MD5)
	-find $(BUILDROOT_OUTPUT)/target -type l -lname '*busybox' -delete 2>/dev/null
	-rm -f $(BUILDROOT_OUTPUT)/target/bin/busybox
else
bclean		:
	$(MAKE) -C $(INSTALL_ROOT)/A2F/busybox clean
endif

aclean		:
	@[ "x$(CUSTOM_APPS)" = "x" ] || \
		for i in $(CUSTOM_APPS); do \
			$(MAKE) -C $$i clean; \
		done
	@[ "x$(XIP_CUSTOM_APPS)" = "x" ] || \
		for i in $(XIP_CUSTOM_APPS); do \
			$(MAKE) -C $$i clean; \
		done

kmenuconfig	: $(SAMPLE).$(KERNEL_CONFIG)
	cp -f $(SAMPLE).$(KERNEL_CONFIG) \
			$(INSTALL_ROOT)/linux/.config
	$(MAKE) -C $(INSTALL_ROOT)/linux menuconfig
	cp -f $(INSTALL_ROOT)/linux/.config \
			./$(SAMPLE).$(KERNEL_CONFIG)

defconfig	:
	cp -f $(KERNEL_DEFCONFIG) \
		$(INSTALL_ROOT)/linux/arch/$(ARCH)/configs/
	$(MAKE) -C $(INSTALL_ROOT)/linux $(KERNEL_DEFCONFIG)
	cp -f $(INSTALL_ROOT)/linux/.config \
			./$(SAMPLE).$(KERNEL_CONFIG)
	rm $(INSTALL_ROOT)/linux/arch/$(ARCH)/configs/$(KERNEL_DEFCONFIG)

savedefconfig	:
	$(MAKE) -C $(INSTALL_ROOT)/linux savedefconfig
	cp $(INSTALL_ROOT)/linux/defconfig $(KERNEL_DEFCONFIG)

ifdef BUILDROOT_DEFCONFIG
BUILDROOT_BB_MD5 := $(BUILDROOT_OUTPUT)/.busybox_config_md5

bmenuconfig	: _buildroot_local_mk
	$(MAKE) -C $(BUILDROOT_DIR) $(BUILDROOT_O) busybox-menuconfig
	cp -f $(BUILDROOT_OUTPUT)/build/busybox-*/\.config $(SAMPLE).busybox
	@md5sum $(SAMPLE).busybox > $(BUILDROOT_BB_MD5)

busybox		: $(SAMPLE).busybox _buildroot_local_mk
	@[ ! -s $(SAMPLE).busybox ] || ( \
		rebuild=0; \
		if [ ! -f $(BUILDROOT_BB_MD5) ] || \
		   [ ! -f $(BUILDROOT_OUTPUT)/target/bin/busybox ]; then \
			rebuild=1; \
		elif ! md5sum --status -c $(BUILDROOT_BB_MD5) 2>/dev/null; then \
			echo "Busybox config changed, rebuilding..."; \
			rebuild=1; \
		fi; \
		if [ $$rebuild -eq 1 ]; then \
			$(MAKE) -C $(BUILDROOT_DIR) $(BUILDROOT_O) busybox-reconfigure; \
			md5sum $(SAMPLE).busybox > $(BUILDROOT_BB_MD5); \
		fi \
	)
else
bmenuconfig	:
	cp -f $(SAMPLE).busybox $(INSTALL_ROOT)/A2F/busybox/.config
	$(MAKE) -C $(INSTALL_ROOT)/A2F/busybox menuconfig
	cp -f $(INSTALL_ROOT)/A2F/busybox/.config $(SAMPLE).busybox

busybox		: $(SAMPLE).busybox
	@[ ! -s $(SAMPLE).busybox ] || \
	(cp -f $(SAMPLE).busybox $(INSTALL_ROOT)/A2F/busybox/.config; \
	 CROSS_COMPILE= $(MAKE) -C $(INSTALL_ROOT)/A2F/busybox)
endif

dtb		: $(SAMPLE).$(KERNEL_DTS)
	cp -f $(SAMPLE).$(KERNEL_DTS) $(KERNEL_DTS_PATH)/$(MCU)-SOM.dts
	cp -f $(SAMPLE).$(KERNEL_CONFIG) $(INSTALL_ROOT)/linux/.config
	$(MAKE) -C $(INSTALL_ROOT)/linux $(DTS_SUBDIR)$(MCU)-SOM.dtb

ifeq ($(SEPARATE_DTB), yes)
UIMAGE_MULI_FLASG :=
CP_DTB		:= cp -f $(KERNEL_DTS_PATH)/$(MCU)-SOM.dtb $(SAMPLE).$(KERNEL_DTB)
else
UIMAGE_MULI_FLASG := UIMAGE_TYPE=multi \
	UIMAGE_IN=$(KERNEL_BOOT)/Image:$(KERNEL_DTS_PATH)/$(MCU)-SOM.dtb
CP_DTB		:=
endif

ifeq ($(MCU),M2S)
UIMAGE_MULI_FLASG :=
CP_DTB		:=
DTB		:=
else
DTB := dtb
endif

$(KERNEL_DEFCONFIG):
	[ ! -e "$(KERNEL_DEFCONFIG)" ] && $(MAKE) savedefconfig

%.$(KERNEL_CONFIG): $(KERNEL_DEFCONFIG)
	$(MAKE) defconfig

%.$(KERNEL_IMAGE) : \
	%.$(KERNEL_CONFIG) %.$(RAMFS_CONFIG) %.$(KERNEL_DTS) \
	$(CUSTOM_APPS) $(XIP_CUSTOM_APPS) busybox $(DTB)
	SAMPLE=$(SAMPLE) ../rfs-builder.py generate-rfs-image $(SAMPLE).$(RAMFS_CONFIG) \
		1 > $(SAMPLE).$(RAMFS_CONFIG).processed
	rm -f $(INSTALL_ROOT)/linux/initramfs-list-min
	ln -s $(INSTALL_ROOT)/projects/$(SAMPLE)/$(SAMPLE).$(RAMFS_CONFIG).processed \
		$(INSTALL_ROOT)/linux/initramfs-list-min

	rm -f $(INSTALL_ROOT)/linux/usr/initramfs_data.cpio \
		$(INSTALL_ROOT)/linux/usr/initramfs_data.cpio.gz
	cp -f $(INSTALL_ROOT)/linux/arch/arm/kernel/vmlinux.lds.S.good \
		$(INSTALL_ROOT)/linux/arch/arm/kernel/vmlinux.lds.S
	([ -e $(SAMPLE).$(KERNEL_LD) ] && \
		cp -f $(SAMPLE).$(KERNEL_LD) \
		$(INSTALL_ROOT)/linux/arch/arm/kernel/vmlinux.lds.S) || \
	true;
	$(UIMAGE_MULI_FLASG) \
	KCFLAGS=$(KERNEL_CFLAGS) $(MAKE) -C $(INSTALL_ROOT)/linux \
		$(KERNEL_IMAGE) SAMPLE=${SAMPLE}
	cp -f $(KERNEL_BOOT)/$(KERNEL_IMAGE) $@
	$(CP_DTB)

# Buildroot targets
ifdef BUILDROOT_DEFCONFIG
.PHONY	: buildroot buildroot-menuconfig buildroot-clean buildroot-sdk _buildroot_check _buildroot_local_mk

BUILDROOT_LOCAL_MK := $(BUILDROOT_OUTPUT)/local.mk

BUILDROOT_BUSYBOX_CONFIG := $(INSTALL_ROOT)/projects/$(SAMPLE)/$(SAMPLE).busybox

_buildroot_local_mk:
	@mkdir -p $(BUILDROOT_OUTPUT)
	@echo 'LINUX_HEADERS_OVERRIDE_SRCDIR = $(INSTALL_ROOT)/linux' > $(BUILDROOT_LOCAL_MK)
	@echo 'BUSYBOX_OVERRIDE_SRCDIR = $(INSTALL_ROOT)/A2F/busybox' >> $(BUILDROOT_LOCAL_MK)
	@echo 'BUSYBOX_CONFIG_FILE = $(BUILDROOT_BUSYBOX_CONFIG)' >> $(BUILDROOT_LOCAL_MK)
	@echo 'BT_TOOLS_OVERRIDE_SRCDIR = $(INSTALL_ROOT)/A2F/bt-tools' >> $(BUILDROOT_LOCAL_MK)

BUILDROOT_DEFCONFIG_PATH := $(BUILDROOT_DIR)/configs/$(BUILDROOT_DEFCONFIG)
BUILDROOT_DEFCONFIG_MD5  := $(BUILDROOT_OUTPUT)/.defconfig_md5

# Re-apply the defconfig only when the defconfig file itself changes
# (md5-tracked) or on first build, so interactive edits made via
# buildroot-menuconfig aren't clobbered. Then always invoke buildroot's
# top-level make: it's a ~4 s no-op when nothing's stale, and it lets
# buildroot's per-package .stamp_* files pick up state changes the
# project make can't see (e.g. a manual <pkg>-dirclean).
_buildroot_check: _buildroot_local_mk
	@if [ ! -x $(BUILDROOT_SENTINEL) ]; then \
		echo "Buildroot toolchain not found. Building (this may take a while)..."; \
		$(MAKE) -C $(BUILDROOT_DIR) $(BUILDROOT_O) $(BUILDROOT_DEFCONFIG) || exit 1; \
		md5sum $(BUILDROOT_DEFCONFIG_PATH) > $(BUILDROOT_DEFCONFIG_MD5); \
	elif [ ! -f $(BUILDROOT_DEFCONFIG_MD5) ] || \
	     ! md5sum --status -c $(BUILDROOT_DEFCONFIG_MD5) 2>/dev/null; then \
		echo "Buildroot config changed. Re-applying defconfig..."; \
		$(MAKE) -C $(BUILDROOT_DIR) $(BUILDROOT_O) $(BUILDROOT_DEFCONFIG) || exit 1; \
		md5sum $(BUILDROOT_DEFCONFIG_PATH) > $(BUILDROOT_DEFCONFIG_MD5); \
	fi
	@$(MAKE) -C $(BUILDROOT_DIR) $(BUILDROOT_O)

buildroot: _buildroot_local_mk
	$(MAKE) -C $(BUILDROOT_DIR) $(BUILDROOT_O) $(BUILDROOT_DEFCONFIG)
	$(MAKE) -C $(BUILDROOT_DIR) $(BUILDROOT_O)
	$(MAKE) -C $(BUILDROOT_DIR) $(BUILDROOT_O) sdk

buildroot-menuconfig: _buildroot_local_mk
	$(MAKE) -C $(BUILDROOT_DIR) $(BUILDROOT_O) $(BUILDROOT_DEFCONFIG)
	$(MAKE) -C $(BUILDROOT_DIR) $(BUILDROOT_O) menuconfig
	$(MAKE) -C $(BUILDROOT_DIR) $(BUILDROOT_O) savedefconfig

buildroot-clean:
	$(MAKE) -C $(BUILDROOT_DIR) $(BUILDROOT_O) clean

buildroot-sdk:
	$(MAKE) -C $(BUILDROOT_DIR) $(BUILDROOT_O) sdk

endif

clone		:
	@[ ! -z ${new} ] || \
	(echo "Please specify the new project name (\"make clone new=...\")";\
		 exit 1);
	@[ ! -d $(INSTALL_ROOT)/projects/${new} ] || \
		(echo \
		"Project $(INSTALL_ROOT)/projects/${new} already exists"; \
		 exit 1);
	@mkdir -p $(INSTALL_ROOT)/projects/${new}
	@cp -a .  $(INSTALL_ROOT)/projects/${new}
	@for i in \
		${KERNEL_CONFIG} \
		${KERNEL_DTS} \
		${KERNEL_LD} \
		${RAMFS_CONFIG} \
		${BUSYBOX_CONFIG}; do \
		[ -e $(INSTALL_ROOT)/projects/${new}/${SAMPLE}.$$i ] && \
		mv $(INSTALL_ROOT)/projects/${new}/${SAMPLE}.$$i \
			$(INSTALL_ROOT)/projects/${new}/${new}.$$i; \
	done
	@rm -f $(INSTALL_ROOT)/projects/${new}/${SAMPLE}.*
	@sed 's/SAMPLE.*\:=.*/SAMPLE\t\t:= ${new}/' Makefile > \
		$(INSTALL_ROOT)/projects/${new}/Makefile
	@echo "New project created in $(INSTALL_ROOT)/projects/${new}"
