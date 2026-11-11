EXEC = hello

CFLAGS		:= -Os -DHELLO_MCU=\"$(MCU)\"
LDFLAGS		:= -static -s

OBJS = hello.o

CC = $(CROSS_COMPILE_APPS)gcc

all: $(EXEC)

$(EXEC): $(OBJS)
	$(CC) $(LDFLAGS) -o $@ $(OBJS) $(LDLIBS)

clean:
	-rm -f $(EXEC) *.gdb *.o .mcu.*

# Rebuild the objects when MCU changes
$(OBJS): .mcu.$(MCU)

.mcu.$(MCU):
	-rm -f .mcu.*
	touch $@
