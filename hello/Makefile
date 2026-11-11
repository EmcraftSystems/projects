# Makefile

SAMPLE		:= hello
CUSTOM_APPS	:= hello

ifeq ($(MCU), $(filter $(MCU), IMXRT102X_NXPEVK IMXRT105X_NXPEVK IMXRT106X_NXPEVK IMXRT117X_NXPEVK MAAXBOARD_RT))
DTS_SUBDIR	:= nxp/imx/
endif

include ../Rules.make

# end of file
