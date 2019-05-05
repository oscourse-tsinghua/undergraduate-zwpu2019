// This is free and unencumbered software released into the public domain.
//
// Anyone is free to copy, modify, publish, use, compile, sell, or
// distribute this software, either in source code form or as a compiled
// binary, for any purpose, commercial or non-commercial, and by any
// means.

#include "firmware.h"

#define OUTPORT 0x02000004      //uart_tx
#define INPORT	0x02000000		//uart_rx


#define uart_status (*(volatile uint32_t*)0x02000008)

void trdy(void) {
	while(!(uart_status & 0x0040));
}

void rrdy(void) {
	while(!(uart_status & 0x0080));
}

char getchar() {
	rrdy();
	return *((volatile uint32_t*)INPORT);
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

void print_dec(unsigned int val)
{
	char buffer[10];
	char *p = buffer;
	while (val || p == buffer) {
		*(p++) = val % 10;
		val = val / 10;
	}
	while (p != buffer) {
		trdy();
		*((volatile uint32_t*)OUTPORT) = '0' + *(--p);
	}
}

void print_hex(unsigned int val, int digits)
{
	for (int i = (4*digits)-4; i >= 0; i -= 4) {
		trdy();
		*((volatile uint32_t*)OUTPORT) = "0123456789ABCDEF"[(val >> i) % 16];
	}
}

