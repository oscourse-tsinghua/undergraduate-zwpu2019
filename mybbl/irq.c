// This is free and unencumbered software released into the public domain.
//
// Anyone is free to copy, modify, publish, use, compile, sell, or
// distribute this software, either in source code form or as a compiled
// binary, for any purpose, commercial or non-commercial, and by any
// means.

#include "firmware.h"

enum sbi_call_t {
	SBI_SET_TIMER = 0,
	SBI_CONSOLE_PUTCHAR = 1,
	SBI_CONSOLE_GETCHAR = 2,
};

// const int SBI_CLEAR_IPI = 3;
// const int SBI_SEND_IPI = 4;
// const int SBI_REMOTE_FENCE_I = 5;
// const int SBI_REMOTE_SFENCE_VMA = 6;
// const int SBI_REMOTE_SFENCE_VMA_ASID = 7;
// const int SBI_SHUTDOWN = 8;

uint32_t *irq(uint32_t *regs, uint32_t irqs)
{
	static unsigned int timer_irq_count = 0;

	uint32_t pc = (regs[0] & 1) ? regs[0] - 3 : regs[0] - 4;
	uint32_t instr = *(uint32_t*)pc;

	if ((irqs & 1) != 0) {
		timer_irq_count++;
		print_str("[TIMER-IRQ]");
		print_dec(timer_irq_count);
		print_str("\r\n");
	}

	if ((irqs & 2) != 0) {
		if (instr == 0x00100073) {
			print_str("EBREAK instruction at 0x");
			print_hex(pc, 8);
			print_str("\r\n");
		} else if (instr == 0x00000073) {
			//print_str("ECALL instruction at 0x");
			//print_hex(pc, 8);
			//print_str("\r\n");

			  int n = regs[17], arg0 = regs[10], retval = 0;

			switch (n)
			{
				case SBI_CONSOLE_PUTCHAR:
					//print_str("It is putchar  ");
					if(arg0 == '\n') {
					    print_chr('\r');
					}
					retval = print_chr(arg0);
					//print_str("\r\n");
					break;
				case SBI_CONSOLE_GETCHAR:
					retval = getchar();
					//print_str("It is getchar\r\n");
					break;
				case SBI_SET_TIMER:
					//retval = mcall_set_timer(arg0 + ((uint64_t)arg1 << 32));
					break;
				default:
					print_str("unrecongnize syscall\r\n");
					retval = 0;
				break;
			}
			regs[11] = retval;
			
		} else {
			print_str("Illegal Instruction at 0x");
			print_hex(pc, 8);
			print_str(": 0x");
			//print_hex(instr, ((instr & 3) == 3) ? 8 : 4);
			print_hex(instr, 8);
			print_str("\r\n");
			
			print_str("------------------------------------------------------------\r\n");
		    for (int i = 0; i < 8; i++)
		    for (int k = 0; k < 4; k++)
		    {
			    int r = i + k*8;

			    if (r == 0) {
				    print_str("pc  ");
			    } else
			    if (r < 10) {
				    print_chr('x');
				    print_chr('0' + r);
				    print_chr(' ');
				    print_chr(' ');
			    } else
			    if (r < 20) {
				    print_chr('x');
				    print_chr('1');
				    print_chr('0' + r - 10);
				    print_chr(' ');
			    } else
			    if (r < 30) {
				    print_chr('x');
				    print_chr('2');
				    print_chr('0' + r - 20);
				    print_chr(' ');
			    } else {
				    print_chr('x');
				    print_chr('3');
				    print_chr('0' + r - 30);
				    print_chr(' ');
			    }

			    print_hex(regs[r], 8);
			    print_str(k == 3 ? "\r\n" : "    ");
		    }

		    print_str("------------------------------------------------------------\r\n");
		}
	}

	if ((irqs & 4) != 0) {
		print_str("It is bus error\r\n");
	}

	return regs;
}

