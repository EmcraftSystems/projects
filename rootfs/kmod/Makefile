obj-m += hello.o

KERNELDIR := $(INSTALL_ROOT)/linux

all:
	make -C $(KERNELDIR) M=`pwd` modules

clean:
	make -C $(KERNELDIR) M=`pwd` clean
	rm -f modules.order
