# Makefile for the LCD test user space program.
all		: crankapi
clean		: clean_apps

# Edit the line below to modify a set of user-space programs
# you need to build

crankapi		: crankapi.c
	$(CC) $(CFLAGS) $< -o $@ $(OBJS) $(LDFLAGS)

# These are flags/tools used to build user-space programs
CFLAGS		:= -Wall -Os -mcpu=cortex-m3 -mthumb -I../uclinux-stm32f7-armle-fbdev-obj/include
LDFLAGS		:= -L../uclinux-stm32f7-armle-fbdev-obj/lib -lgreio
CC		= $(CROSS_COMPILE_APPS)gcc

# Clean-up after user-space programs
clean_apps	:
	-rm -f crankapi *.gdb *.o
