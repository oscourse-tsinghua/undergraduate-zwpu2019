RISCV_GNU_TOOLCHAIN_INSTALL_PREFIX = /home/z/riscv32-unknown-elf-gcc

SHELL = bash

FIRMWARE_OBJS = Start.o Hello.o print.o


GCC_WARNS  = -Wall

TOOLCHAIN_PREFIX = $(RISCV_GNU_TOOLCHAIN_INSTALL_PREFIX)/bin/riscv32-unknown-elf-

copy: hello
	cp hello ../mybbl/
asm: hello
	$(TOOLCHAIN_PREFIX)objdump -d hello | less

hello: $(FIRMWARE_OBJS) sections.lds
	$(TOOLCHAIN_PREFIX)gcc -Os -g -ffreestanding -nostdlib -o $@ \
		-Wl,-Bstatic,-T,sections.lds,-Map,Hello.map \
		$(FIRMWARE_OBJS) -lgcc

Start.o: Start.S
	$(TOOLCHAIN_PREFIX)gcc -c -march=rv32im -o $@ $<

%.o: %.c
	$(TOOLCHAIN_PREFIX)gcc -c -march=rv32im -Os -g --std=c99 $(GCC_WARNS) -ffreestanding -nostdlib -o $@ $<

clean:	
	rm -vr $(FIRMWARE_OBJS) hello Hello.map 

.PHONY:  clean
