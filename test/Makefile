RISCV_GNU_TOOLCHAIN_INSTALL_PREFIX = /opt/riscv32

SHELL = bash

TEST_OBJS = $(addsuffix .o,$(basename $(wildcard test3/*.S)))

# FIRMWARE_OBJS = firmware/start.o firmware/irq.o firmware/print.o firmware/sieve.o firmware/multest.o firmware/stats.o
FIRMWARE_OBJS = firmware/start.o

GCC_WARNS  = -Werror -Wall -Wextra -Wshadow -Wundef -Wpointer-arith -Wcast-qual -Wcast-align -Wwrite-strings
GCC_WARNS += -Wredundant-decls -Wstrict-prototypes -Wmissing-prototypes -pedantic # -Wconversion

TOOLCHAIN_PREFIX = $(RISCV_GNU_TOOLCHAIN_INSTALL_PREFIX)im/bin/riscv32-unknown-elf-

firmware.hex: firmware/firmware.coe
	./coe2hex

firmware/firmware.coe: firmware/firmware.bin
	./bin2coe.py 32 < firmware/firmware.bin > firmware/firmware.coe

firmware/firmware.bin: firmware/firmware.elf
	$(TOOLCHAIN_PREFIX)objcopy -O binary $< $@

firmware/firmware.elf: $(FIRMWARE_OBJS) $(TEST_OBJS) firmware/sections.lds
	$(TOOLCHAIN_PREFIX)gcc -Os -g -ffreestanding -nostdlib -o $@ \
		-Wl,-Bstatic,-T,firmware/sections.lds,-Map,firmware/firmware.map,--strip-debug \
		$(FIRMWARE_OBJS) $(TEST_OBJS) -lgcc

firmware/start.o: firmware/start.S
	$(TOOLCHAIN_PREFIX)gcc -c -march=rv32im -o $@ $<


test3/%.o: test3/%.S test3/riscv_test.h test3/test_macros.h
	$(TOOLCHAIN_PREFIX)gcc -c -march=rv32im -o $@ -DTEST_FUNC_NAME=$(notdir $(basename $<)) \
		-DTEST_FUNC_TXT='"$(notdir $(basename $<))"' -DTEST_FUNC_RET=$(notdir $(basename $<))_ret $<

clean:	
	rm -vrf $(FIRMWARE_OBJS) $(TEST_OBJS) firmware/firmware.elf firmware/firmware.bin firmware/firmware.hex firmware/firmware.map 

.PHONY:  clean
