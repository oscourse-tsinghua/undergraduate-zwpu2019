#include "firmware.h"

#define uart_status (*(volatile uint32_t*)0x02000008)

void trdy(void) {
	while(!(uart_status & 0x0040));
}
