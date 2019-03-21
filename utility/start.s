.section .text

start:

# zero-initialize register file
addi x1, zero, 0
li   x2, 0x5000
addi x3, zero, 0
addi x4, zero, 0
addi x5, zero, 0
addi x6, zero, 0
addi x7, zero, 0
addi x8, zero, 0
addi x9, zero, 0
addi x10, zero, 0
addi x11, zero, 0
addi x12, zero, 0
addi x13, zero, 0
addi x14, zero, 0
addi x15, zero, 0
addi x16, zero, 0
addi x17, zero, 0
addi x18, zero, 0
addi x19, zero, 0
addi x20, zero, 0
addi x21, zero, 0
addi x22, zero, 0
addi x23, zero, 0
addi x24, zero, 0
addi x25, zero, 0
addi x26, zero, 0
addi x27, zero, 0
addi x28, zero, 0
addi x29, zero, 0
addi x30, zero, 0
addi x31, zero, 0

/*
lui  x3, 0x02000
lw   x5, 0x8(x3)
sb   zero, 0x4(x3)

addi x6, x6, 0x60
wait:
lw   x5, 0x8(x3)
andi  x5, x5, 0x60
bne  x5, x6, wait

sw   zero, 0x4(x3)


lui  x3, 0x03000
lb   x4, 0x10(x3)


lui  x3, 0x04000
sb   x4, 0x0(x3)
sb   x4, 0x10(x3)

addi x3, zero, 0
addi x4, zero, 0
*/

# call main
call main
loop:
j loop

