#include <stdint.h>
#include <stdbool.h>

// irq.c
uint32_t *irq(uint32_t *regs, uint32_t irqs);

//  print.c
// uintptr_t print_chr(char ch);
// uintptr_t getchar();
int print_chr(char ch);
char getchar(void);

void print_str(const char *p);
void print_dec(unsigned int val);
void print_hex(unsigned int val, int digits);
