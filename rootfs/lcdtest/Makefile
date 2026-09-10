# Makefile for the LCD test user space program.
all		: apps
clean		: clean_apps

CC = $(CROSS_COMPILE_APPS)gcc
STRIP = $(CROSS_COMPILE_APPS)strip --strip-unneeded
CFLAGS		:= -Os -I$(TOOLS_LIBS)/usr/include
LDFLAGS		:= -L$(TOOLS_LIBS)/usr/lib

# Edit the line below to modify a set of user-space programs
# you need to build
APPS		= lcdtest ts_test
apps		: $(APPS)
	$(STRIP) $^

ts_test:	ts_test.o fbutils.o font_8x16.o font_8x8.o
	$(CC) $(LDFLAGS) -o $@ $^ -lts
%.o:		%.c
	$(CC) -c $(CFLAGS) -o $@ $^

# Clean-up after user-space programs
clean_apps	:
	-rm -f $(APPS) *.gdb *.o
