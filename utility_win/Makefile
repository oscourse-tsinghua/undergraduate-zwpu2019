RISCV_GNU_TOOLCHAIN_INSTALL_PREFIX = /opt/riscv32
TOOLCHAIN_PREFIX = $(RISCV_GNU_TOOLCHAIN_INSTALL_PREFIX)im/bin/
# ---- iCE40 HX8K Breakout Board ----

hx8kdemo_fw.hex: hx8kdemo_fw.coe
	./coe2hex

hx8kdemo_fw.coe: hx8kdemo_fw.bin
	./bin2coe.py 32 < hx8kdemo_fw.bin > hx8kdemo_fw.coe

hx8kdemo_fw.bin: hx8kdemo_fw.elf
	$(TOOLCHAIN_PREFIX)riscv32-unknown-elf-objcopy -O binary hx8kdemo_fw.elf hx8kdemo_fw.bin

hx8kdemo_fw.elf: sections.lds start.s firmware.c
	$(TOOLCHAIN_PREFIX)riscv32-unknown-elf-gcc -DHX8KDEMO -march=rv32im -Wl,-Bstatic,-T,sections.lds,--strip-debug -ffreestanding -nostdlib -o hx8kdemo_fw.elf start.s firmware.c

# ---- Clean ----

clean:
	rm -f hx8kdemo_fw.elf hx8kdemo_fw.hex hx8kdemo_fw.bin

.PHONY: clean

