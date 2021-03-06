RISCV_GNU_TOOLCHAIN_INSTALL_PREFIX = /opt/riscv32

SHELL = bash

TEST_OBJS = $(addsuffix .o,$(basename $(wildcard tests/*.S)))

FIRMWARE_OBJS = firmware/start.o firmware/irq.o firmware/trdy.o firmware/print.o


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
		-Wl,-Bstatic,-T,firmware/sections.lds,-Map,firmware/firmware.map \
		$(FIRMWARE_OBJS) $(TEST_OBJS) -lgcc

firmware/start.o: firmware/start.S
	$(TOOLCHAIN_PREFIX)gcc -c -march=rv32im -o $@ $<

firmware/%.o: firmware/%.c
	$(TOOLCHAIN_PREFIX)gcc -c -march=rv32im -Os --std=c99 $(GCC_WARNS) -ffreestanding -nostdlib -o $@ $<


tests/%.o: tests/%.S tests/riscv_test.h tests/test_macros.h
	$(TOOLCHAIN_PREFIX)gcc -c -march=rv32im -o $@ -DTEST_FUNC_NAME=$(notdir $(basename $<)) \
		-DTEST_FUNC_TXT='"$(notdir $(basename $<))"' -DTEST_FUNC_RET=$(notdir $(basename $<))_ret $<

clean:	
	rm -vrf $(FIRMWARE_OBJS) $(TEST_OBJS) firmware/firmware.elf firmware/firmware.bin firmware/firmware.hex firmware/firmware.map 

.PHONY:  clean
