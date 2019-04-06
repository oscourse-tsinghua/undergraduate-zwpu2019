// This is free and unencumbered software released into the public domain.
//
// Anyone is free to copy, modify, publish, use, compile, sell, or
// distribute this software, either in source code form or as a compiled
// binary, for any purpose, commercial or non-commercial, and by any
// means.

#define ENABLE_QREGS
#define ENABLE_RVTST


#include "custom_ops.S"

	.section .text
	.global irq
/* Main program
 **********************************/

start:
	/* zero-initialize all registers */

	addi x1, zero, 0
	addi x2, zero, 0
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


	# copy data section
	la a0, _sidata
	la a1, _sdata
	la a2, _edata
	bge a1, a2, end_init_data
	loop_init_data:
	lw a3, 0(a0)
	sw a3, 0(a1)
	addi a0, a0, 4
	addi a1, a1, 4
	blt a1, a2, loop_init_data
	end_init_data:


	# zero-init bss section
	la a0, _sbss
	la a1, _ebss
	bge a0, a1, end_init_bss
	loop_init_bss:
	sw zero, 0(a0)
	addi a0, a0, 4
	blt a0, a1, loop_init_bss
	end_init_bss:


	/* running tests from riscv-tests */

#ifdef ENABLE_RVTST
#  define TEST(n) \
	.global n; \
	addi x1, zero, 1000; \
	picorv32_timer_insn(zero, x1); \
	jal zero,n; \
	.global n ## _ret; \
	n ## _ret:
#else
#  define TEST(n) \
	.global n ## _ret; \
	n ## _ret:
#endif
/*
	TEST(lui)
	TEST(auipc)
	TEST(j)
	TEST(jal)
	TEST(jalr)

	TEST(beq)
	TEST(bne)
	TEST(blt)
	TEST(bge)
	TEST(bltu)
	TEST(bgeu)

	TEST(lb)
	TEST(lh)
	TEST(lw)
	TEST(lbu)
	TEST(lhu)

	TEST(sb)
	TEST(sh)
	TEST(sw)
*/
/*
	TEST(addi)
	TEST(slti) // also tests sltiu
	TEST(xori)
	TEST(ori)
	TEST(andi)
	TEST(slli)
	TEST(srli)
	TEST(srai)


	TEST(add)
	TEST(sub)
	TEST(sll)
	TEST(slt) // what is with sltu ?
	TEST(xor)
	TEST(srl)
	TEST(sra)
	TEST(or)
	TEST(and)

*/
	TEST(mulh)
	TEST(mulhsu)
	TEST(mulhu)
	TEST(mul)

	TEST(div)
	TEST(divu)
	TEST(rem)
	TEST(remu)

	TEST(simple)

	/* set stack pointer */
	lui sp,(64*1024)>>12

	/* set gp and tp */
	lui gp, %hi(0xdeadbeef)
	addi gp, gp, %lo(0xdeadbeef)
	addi tp, gp, 0

done:
	/* print "DONE\n" */
	lui a0,0x02000000>>12
	addi a0, a0, 4

	addi a1,zero,'D'
	addi a2,zero,'O'
	addi a3,zero,'N'
	addi a4,zero,'E'
	addi a5,zero,'\r'
	addi a6,zero,'\n'
	sw a1,0(a0)
	sw a2,0(a0)
	sw a3,0(a0)
	sw a4,0(a0)
	sw a5,0(a0)
	sw a6,0(a0)
loop:
		
	//sw a6,0(a0)
	//sw a5,0(a0)
	//sw a4,0(a0)
	j loop

