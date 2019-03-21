#include <stdint.h>
#include <stdbool.h>

#define uart_rx (*(volatile uint32_t*)0x02000000)
#define uart_tx (*(volatile uint32_t*)0x02000004)
#define uart_divisor (*(volatile uint32_t*)0x02000010)

#define reg_gpio (*(volatile uint32_t*)0x03000000)
#define reg_seg1 (*(volatile uint32_t*)0x04000000)
#define reg_seg2 (*(volatile uint32_t*)0x04000010)
int main()
{
	char greet[] = "Booting......\n\r.";
	int i = 0;
	int j = 0;
	uint32_t tmp;

	reg_seg1 = ( uart_divisor >> 8 ) & 15;
	reg_seg2 = ( uart_divisor >> 4 ) & 15;
	reg_gpio = ~(( uart_divisor >> 0 ) & 15);

	for(j = 0; j < 15; j++) {
		uart_tx = greet[j];
		reg_gpio = 255 >> j;
		for(i = 0; i < 30000; i++);
	}
	while(1) {		
		for(j = 0; j < 15; j++) {
			reg_gpio = 255 >> j;
			tmp = uart_rx;
			if(tmp != 0xffffffff) {
				uart_tx = tmp;
			}
			for(i = 0; i < 50000; i++);
		}
	}

	return 0;
}
