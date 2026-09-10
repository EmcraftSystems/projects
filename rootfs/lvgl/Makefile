#
# Makefile
#
ifeq ($(MCU), $(filter $(MCU), IMXRT105X_NXPEVK IMXRT106X_NXPEVK IMXRT117X_NXPEVK MAAXBOARD_RT))

USE_PREBUILT_DEMOS := yes

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

endif # USE_PREBUILT_DEMOS

else # MCU == IMXRT1050-EVK

default:

endif

all: default
