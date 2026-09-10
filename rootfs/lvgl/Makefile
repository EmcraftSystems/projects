#
# Makefile
#
ifeq ($(MCU), $(filter $(MCU), IMXRT105X_NXPEVK IMXRT106X_NXPEVK IMXRT117X_NXPEVK MAAXBOARD_RT))

USE_PREBUILT_DEMOS := no

BINS = stress benchmark widgets music
ifeq ($(MCU), $(filter $(MCU), IMXRT105X_NXPEVK IMXRT106X_NXPEVK))
BINS += ebike
endif
LVGLLIBS = liblvgl.so

default: $(LVGLLIBS) $(BINS)

ifeq ($(USE_PREBUILT_DEMOS), yes)

LVGL_DEMOS_DIR := $(INSTALL_ROOT)/A2F/lvgl_bins/$(MCU)

liblvgl.so: $(LVGL_DEMOS_DIR)/liblvgl.so
	cp $< $@

stress: $(LVGL_DEMOS_DIR)/stress
	cp $< $@

benchmark: $(LVGL_DEMOS_DIR)/benchmark
	cp $< $@

widgets: $(LVGL_DEMOS_DIR)/widgets
	cp $< $@

music: $(LVGL_DEMOS_DIR)/music
	cp $< $@

ebike: $(LVGL_DEMOS_DIR)/ebike
	cp $< $@

clean:
	rm -f $(LVGLLIBS) $(BINS)

else # USE_PREBUILT_DEMOS != yes

LVGL_DIR_NAME = lvgl
LVGL_DIR = $(INSTALL_ROOT)/A2F
LVGL_PROJECT_DIR = ${shell pwd}

CC = $(CROSS_COMPILE_APPS)gcc
CFLAGS := -Os -I$(INSTALL_ROOT)/A2F/root/usr/include -I$(LVGL_DIR)/$(LVGL_DIR_NAME) -Wall -Wshadow -Wundef -Wmissing-prototypes -Wno-discarded-qualifiers -Wall -Wextra

CFLAGS += -DLV_CONF_INCLUDE_SIMPLE  -I$(LVGL_PROJECT_DIR)/$(MCU)

LDFLAGS := -L$(INSTALL_ROOT)/A2F/root/usr/lib

STRIP = $(CROSS_COMPILE_APPS)strip --strip-unneeded

#Collect the files to compile
MAINSRC = ./main.c

include $(LVGL_DIR)/$(LVGL_DIR_NAME)/src/core/lv_core.mk
include $(LVGL_DIR)/$(LVGL_DIR_NAME)/src/draw/lv_draw.mk
include $(LVGL_DIR)/$(LVGL_DIR_NAME)/src/extra/lv_extra.mk
include $(LVGL_DIR)/$(LVGL_DIR_NAME)/src/font/lv_font.mk
include $(LVGL_DIR)/$(LVGL_DIR_NAME)/src/hal/lv_hal.mk
include $(LVGL_DIR)/$(LVGL_DIR_NAME)/src/misc/lv_misc.mk
include $(LVGL_DIR)/$(LVGL_DIR_NAME)/src/widgets/lv_widgets.mk
include $(LVGL_DIR)/lv_drivers/lv_drivers.mk

STRESSSRCS = $(shell find -L $(LVGL_DIR)/$(LVGL_DIR_NAME)/demos/stress -name "*.c")
BENCHMARKSRCS = $(shell find -L $(LVGL_DIR)/$(LVGL_DIR_NAME)/demos/benchmark -name "*.c")
WIDGETSSRCS = $(shell find -L $(LVGL_DIR)/$(LVGL_DIR_NAME)/demos/widgets -name "*.c")
MUSICSRCS = $(shell find -L $(LVGL_DIR)/$(LVGL_DIR_NAME)/demos/music -name "*.c")
EBIKESRCS = $(shell find -L $(LVGL_PROJECT_DIR)/ebike_ui -name "*.c")

OBJEXT ?= .o

AOBJS = $(ASRCS:.S=$(OBJEXT))
COBJS = $(CSRCS:.c=$(OBJEXT))

MAINOBJ = $(MAINSRC:.c=$(OBJEXT))

SRCS = $(ASRCS) $(CSRCS)
OBJS = $(AOBJS) $(COBJS)

STRESSOBJS = $(STRESSSRCS:.c=$(OBJEXT))

BENCHMARKOBJS = $(BENCHMARKSRCS:.c=$(OBJEXT))

WIDGETSOBJS = $(WIDGETSSRCS:.c=$(OBJEXT))

MUSICOBJS = $(MUSICSRCS:.c=$(OBJEXT))

EBIKEOBJS = $(EBIKESRCS:.c=$(OBJEXT))

liblvgl.so: $(AOBJS) $(COBJS)
	$(CC) -shared -o $@ $(AOBJS) $(COBJS) $(LDFLAGS)
	$(STRIP) $@

stress: $(STRESSOBJS) $(LVGLLIBS) $(MAINSRC)
	$(CC) $(CFLAGS) -o $@ $(STRESSOBJS) -D BUILD_DEMO_STRESS $(MAINSRC) -L. -llvgl
	$(STRIP) $@

benchmark: $(BENCHMARKOBJS) $(LVGLLIBS) $(MAINSRC)
	$(CC) $(CFLAGS) -o $@ $(BENCHMARKOBJS) -D BUILD_DEMO_BENCHMARK $(MAINSRC) -L. -llvgl
	$(STRIP) $@

widgets: $(WIDGETSOBJS) $(LVGLLIBS) $(MAINSRC)
	$(CC) $(CFLAGS) -o $@ $(WIDGETSOBJS) -D BUILD_DEMO_WIDGETS $(MAINSRC) -L. -llvgl
	$(STRIP) $@

music: $(MUSICOBJS) $(LVGLLIBS) $(MAINSRC)
	$(CC) $(CFLAGS) -o $@ $(MUSICOBJS) -D BUILD_DEMO_MUSIC $(MAINSRC) -L. -llvgl
	$(STRIP) $@

ebike: $(EBIKEOBJS) $(LVGLLIBS) $(MAINSRC)
	$(CC) $(CFLAGS) -o $@ $(EBIKEOBJS) $(MAINSRC) -D BUILD_DEMO_EBIKE -L. -llvgl
	$(STRIP) $@

%.o: %.c $(LVGL_PROJECT_DIR)/$(MCU)/lv_conf.h $(LVGL_PROJECT_DIR)/$(MCU)/lv_drv_conf.h
	@$(CC)  $(CFLAGS) -c $< -o $@
	@echo "CC $<"

clean:
	rm -f $(BINS) $(LVGLLIBS) $(AOBJS) $(COBJS) $(MAINOBJ) $(STRESSOBJS) $(MUSICOBJS) $(WIDGETSOBJS) $(BENCHMARKOBJS) $(EBIKEOBJS)

endif # USE_PREBUILT_DEMOS

else # MCU == IMXRT1050-EVK

default:

endif

all: default
