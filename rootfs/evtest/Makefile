# Makefile for the faulting user space programs

all		: apps
clean		: clean_apps

CC = $(CROSS_COMPILE_APPS)gcc
STRIP = $(CROSS_COMPILE_APPS)strip --strip-unneeded
CFLAGS		:= -Os

# Edit the line below to modify a set of user-space programs
# you need to build
APPS		= evtest
apps		: $(APPS)
	$(STRIP) $^

%.o:		%.c
	$(CC) -c $(CFLAGS) -o $@ $^

# Clean-up after user-space programs
clean_apps	:
	-rm -f $(APPS) *.gdb *.o
