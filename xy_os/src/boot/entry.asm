.section .text
    .global _start
_start:
    # li x17, 1		//putchar syscall
    # addi x10,zero,'S'	
    # ecall
	
    add t0, zero, 1
    slli t0, t0, 16

    lui sp, %hi(bootstacktop)
    addi sp, sp, %lo(bootstacktop)
    # add sp, sp, t0

    # li x17, 1		//putchar syscall
    # addi x10,zero,'R'	
    # ecall
	
    call rust_main


    .section .data
    .align 4 
    .global bootstack
bootstack:
    .space 2048
    .global bootstacktop
bootstacktop:
