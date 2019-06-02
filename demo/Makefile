RISCV_GNU_TOOLCHAIN_INSTALL_PREFIX = /home/z/riscv32-unknown-elf-gcc

SHELL = bash

FIRMWARE_OBJS = start.o main.o irq.o print.o sieve.o stats.o logo.o raw_logo.o test.o


GCC_WARNS  = -Wall
TOOLCHAIN_PREFIX = $(RISCV_GNU_TOOLCHAIN_INSTALL_PREFIX)/bin/riscv32-unknown-elf-

firmware.hex: firmware.coe
	./coe2hex

firmware.coe: firmware.bin
	./bin2coe.py 32 < firmware.bin > firmware.coe

firmware.bin: firmware.elf
	$(TOOLCHAIN_PREFIX)objcopy -O binary $< $@

firmware.elf: $(FIRMWARE_OBJS) sections.lds
	$(TOOLCHAIN_PREFIX)gcc  -g -ffreestanding -nostdlib -o $@ \
		-Wl,-Bstatic,-T,sections.lds,-Map,firmware.map,--strip-debug \
		$(FIRMWARE_OBJS) -lgcc

start.o: start.S
	$(TOOLCHAIN_PREFIX)gcc -c -march=rv32im -o $@ $<

raw_logo.o: raw_logo.S
	$(TOOLCHAIN_PREFIX)gcc -c -march=rv32im -o $@ $<
	
%.o: %.c
	$(TOOLCHAIN_PREFIX)gcc -c -march=rv32im  --std=c99 $(GCC_WARNS) -ffreestanding -nostdlib -o $@ $<
	
clean:	
	rm -vrf $(FIRMWARE_OBJS) firmware.elf firmware.bin firmware.hex firmware.map 

asm: 
	$(TOOLCHAIN_PREFIX)objdump -d firmware.elf | less
.PHONY:  clean asm
