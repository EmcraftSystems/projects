#
# Builds the Cortex-M4 RPMsg ping-pong firmware with cmake and the
# arm-none-eabi toolchain under $(ARMGCC_DIR).
#
DIR_EXAMPLE	:= rpmsg_lite_pingpong_rtos_cm4
ELF		:= $(DIR_EXAMPLE)/release/$(DIR_EXAMPLE).elf
ARMGCC_DIR	?= /usr

# The firmware has its own compiler flags; drop the ones meant for Linux apps.
BUILD_ENV	:= env -u CFLAGS -u LDFLAGS ARMGCC_DIR=$(ARMGCC_DIR)

all:
	@command -v cmake >/dev/null || \
		{ echo "cmake not found"; exit 1; }
	@[ -x "$(ARMGCC_DIR)/bin/arm-none-eabi-gcc" ] || \
		{ echo "$(ARMGCC_DIR)/bin/arm-none-eabi-gcc not found; set ARMGCC_DIR"; exit 1; }
	rm -rf $(ELF) $(DIR_EXAMPLE)/CMakeCache.txt $(DIR_EXAMPLE)/CMakeFiles
	cd $(DIR_EXAMPLE) && $(BUILD_ENV) cmake -DCMAKE_TOOLCHAIN_FILE=armgcc.cmake \
		-G "Unix Makefiles" -DCMAKE_BUILD_TYPE=release .
	$(BUILD_ENV) $(MAKE) -C $(DIR_EXAMPLE)
	@test -f $(ELF)

clean:
	rm -rf $(DIR_EXAMPLE)/release $(DIR_EXAMPLE)/debug \
		$(DIR_EXAMPLE)/CMakeFiles $(DIR_EXAMPLE)/CMakeCache.txt \
		$(DIR_EXAMPLE)/Makefile $(DIR_EXAMPLE)/cmake_install.cmake \
		$(DIR_EXAMPLE)/output.map

.PHONY: all clean
