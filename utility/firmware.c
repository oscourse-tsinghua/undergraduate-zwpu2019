#include <stdint.h>
#include <stdbool.h>

#define uart_rx (*(volatile uint32_t*)0x02000000)
#define uart_tx (*(volatile uint32_t*)0x02000004)
#define uart_divisor (*(volatile uint32_t*)0x02000010)
#define uart_status (*(volatile uint32_t*)0x02000008)

#define reg_gpio (*(volatile uint32_t*)0x03000000)
#define reg_seg1 (*(volatile uint32_t*)0x04000000)
#define reg_seg2 (*(volatile uint32_t*)0x04000010)
int main()
{
	char greet[] = "Booting......\n\r.";
	int i = 0;
	int j = 0;
	int div = 104;
	char tmp;

	reg_seg1 = ( uart_divisor >> 8 ) & 15;
	reg_seg2 = ( uart_divisor >> 4 ) & 15;
	reg_gpio = ~(( uart_divisor >> 0 ) & 15);
	for(i = 0; i < 1000000; i++);

	uart_divisor = div;
	reg_seg1 = ( uart_divisor >> 4 ) & 15;
	reg_seg2 = ( uart_divisor >> 0 ) & 15;

		

	while(1) {		
		for(j = 0; j < 15; j++) {
			uart_tx = greet[j];
			reg_gpio = 255 >> j;
			
			if(uart_status & 0x0080) {
				tmp = uart_tx;
				greet[j] = 'C';		
			}
			for(i = 0; i < 100000; i++);
		}
	}

	return 0;
}
