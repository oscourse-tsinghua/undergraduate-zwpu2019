// This is free and unencumbered software released into the public domain.
//
// Anyone is free to copy, modify, publish, use, compile, sell, or
// distribute this software, either in source code form or as a compiled
// binary, for any purpose, commercial or non-commercial, and by any
// means.

#include<stdint.h>
#include<stdbool.h>

#define OUTPORT 0x02000004      //uart_tx
#define INPORT	0x02000000		//uart_rx


#define uart_status (*(volatile uint32_t*)0x02000008)

void trdy(void) {
	while(!(uart_status & 0x0040));
}


int print_chr(char ch)
{
	trdy();
	*((volatile uint32_t*)OUTPORT) = ch;
	return 0;
}

void print_str(const char *p)
{
	while (*p != 0) {
		trdy();
		*((volatile uint32_t*)OUTPORT) = *(p++);
	}
}
