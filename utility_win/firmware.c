#include <stdint.h>
#include <stdbool.h>

#define uart_tx (*(volatile uint32_t*)0x02000008)
#define uart_divisor (*(volatile uint32_t*)0x02000004)

int main()
{
	char greet[] = "Booting......\n.";
	int i = 0;
	int j = 0;

	
	while(1) {	
		for(j = 0; j < 14; j++) {
			uart_tx = greet[j];
			for(i = 0; i < 50000; i++);
		}
	}

	return 0;
}
