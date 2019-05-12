#include "custom_ops.S"


	.section .text
	.global irq 
	.global reset_vec 
    
reset_vec:
	// no more than 16 bytes here
	
	j _start


/* Interrupt handler
 **********************************/

.balign 16
irq_vec:
    
	/* save registers */
	picorv32_setq_insn(q2, x1)
	picorv32_setq_insn(q3, x2)

       //关中断
	addi x1, zero, -1
	picorv32_maskirq_insn(zero, x1)
    
	lui x1, %hi(irq_regs)
	addi x1, x1, %lo(irq_regs)

	picorv32_getq_insn(x2, q0)
	sw x2,   0*4(x1)

	picorv32_getq_insn(x2, q2)
	sw x2,   1*4(x1)

	picorv32_getq_insn(x2, q3)
	sw x2,   2*4(x1)
	sw x3,   3*4(x1)
	sw x4,   4*4(x1)
	sw x5,   5*4(x1)
	sw x6,   6*4(x1)
	sw x7,   7*4(x1)
	sw x8,   8*4(x1)
	sw x9,   9*4(x1)
	sw x10, 10*4(x1)
	sw x11, 11*4(x1)
	sw x12, 12*4(x1)
	sw x13, 13*4(x1)
	sw x14, 14*4(x1)
	sw x15, 15*4(x1)
	sw x16, 16*4(x1)
	sw x17, 17*4(x1)
	sw x18, 18*4(x1)
	sw x19, 19*4(x1)
	sw x20, 20*4(x1)
	sw x21, 21*4(x1)
	sw x22, 22*4(x1)
	sw x23, 23*4(x1)
	sw x24, 24*4(x1)
	sw x25, 25*4(x1)
	sw x26, 26*4(x1)
	sw x27, 27*4(x1)
	sw x28, 28*4(x1)
	sw x29, 29*4(x1)
	sw x30, 30*4(x1)
	sw x31, 31*4(x1)


	/* call interrupt handler C function */

	lui sp, %hi(irq_stack)
	addi sp, sp, %lo(irq_stack)

	// arg0 = address of regs
	lui a0, %hi(irq_regs)
	addi a0, a0, %lo(irq_regs)

	// arg1 = interrupt type
	picorv32_getq_insn(a1, q1)


	// call to C function
	jal ra, irq

	/* restore registers */

	// new irq_regs address returned from C code in a0
	addi x1, a0, 0

	lw x2,   0*4(x1)
	picorv32_setq_insn(q0, x2)

	lw x2,   1*4(x1)
	picorv32_setq_insn(q1, x2)

	lw x2,   2*4(x1)
	picorv32_setq_insn(q2, x2)

	lw x3,   3*4(x1)
	lw x4,   4*4(x1)
	lw x5,   5*4(x1)
	lw x6,   6*4(x1)
	lw x7,   7*4(x1)
	lw x8,   8*4(x1)
	lw x9,   9*4(x1)
	lw x10, 10*4(x1)
	lw x11, 11*4(x1)
	lw x12, 12*4(x1)
	lw x13, 13*4(x1)
	lw x14, 14*4(x1)
	lw x15, 15*4(x1)
	lw x16, 16*4(x1)
	lw x17, 17*4(x1)
	lw x18, 18*4(x1)
	lw x19, 19*4(x1)
	lw x20, 20*4(x1)
	lw x21, 21*4(x1)
	lw x22, 22*4(x1)
	lw x23, 23*4(x1)
	lw x24, 24*4(x1)
	lw x25, 25*4(x1)
	lw x26, 26*4(x1)
	lw x27, 27*4(x1)
	lw x28, 28*4(x1)
	lw x29, 29*4(x1)
	lw x30, 30*4(x1)
	lw x31, 31*4(x1)

	#set timer
	lui x1, 10000; 
	picorv32_timer_insn(zero, x1); 


	picorv32_getq_insn(x1, q1)
	picorv32_getq_insn(x2, q2)

    //开中断
    picorv32_maskirq_insn(zero, zero)
	picorv32_retirq_insn()


/* Main program
 **********************************/

_start:
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
	
#set divisor
	lui a0, 0x02000
	li a1, 0x68
	sw a1, 0x10(a0)

	/* set stack pointer */
	lui sp,0x00011

	/* set gp and tp */
	lui gp, %hi(0xdeadbeef)
	addi gp, gp, %lo(0xdeadbeef)
	addi tp, gp, 0

	/* print "BOOT\n" */
	lui a0,0x02000
	addi a0,a0,0x4
	jal ra, trdy
	addi a1,zero,'B'
	sw a1,0(a0)
	jal ra, trdy
	addi a1,zero,'O'
	sw a1,0(a0)
	jal ra, trdy
	addi a1,zero,'O'
	sw a1,0(a0)
	jal ra, trdy
	addi a1,zero,'T'
	sw a1,0(a0)
	jal ra, trdy
	addi a1,zero,'\r'
	sw a1,0(a0)
	jal ra, trdy
	addi a1,zero,'\n'
	sw a1,0(a0)

#set irq_mask
	picorv32_maskirq_insn(zero, zero)
	
//	li x17, 1		//putchar syscall
//	addi x10,zero,'H'	
//	ecall

	ebreak

#set timer
	lui x1, 10000; 
	picorv32_timer_insn(zero, x1); 


led:
	lui a0, 0x03000
	li a1, 0xff00
	li a2, 2
loop:
	srl a3, a1, a2
	sw  a3, 0x0(a0)

	picorv32_waitirq_insn(zero)
	addi a2, a2, -1
	bgt a2, zero, loop

	j text_payload_start

	# /* print "DONE\n" */
	# lui a0,0x02000
	# addi a0,a0,0x4
	# jal ra, trdy
	# addi a1,zero,'D'
	# sw a1,0(a0)
	# jal ra, trdy
	# addi a1,zero,'O'
	# sw a1,0(a0)
	# jal ra, trdy
	# addi a1,zero,'N'
	# sw a1,0(a0)
	# jal ra, trdy
	# addi a1,zero,'E'
	# sw a1,0(a0)
	# jal ra, trdy
	# addi a1,zero,'\r'
	# sw a1,0(a0)
	# jal ra, trdy
	# addi a1,zero,'\n'
	# sw a1,0(a0)

	# j		loop				# jump to loop

.org 0x1000
   .globl text_payload_start, text_payload_end
text_payload_start:
   .incbin "xy_os.text"
text_payload_end:


.org 0x9000 
    .global _elf_payload_start, _elf_payload_end
_elf_payload_start:
    .incbin "hello"
_elf_payload_end:


    .balign 4
    .section .data
irq_regs:
	// registers are saved to this memory region during interrupt handling
	// the program counter is saved as register 0
	.fill 32,4

	// stack for the interrupt handler
	.fill 128,4
irq_stack:

.org 0x300
   .globl data_payload_start, data_payload_end
data_payload_start:
   .incbin "xy_os.data"
data_payload_end:
