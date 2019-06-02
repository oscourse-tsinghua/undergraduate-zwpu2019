#include"firmware.h"
#define INPORT	0x02000000		//uart_rx
void test() {
    char tmp;
    print_logo();
    print_str("Here is test.............................\n");
    print_str("press 'q' to continue....................\n");
    while(1) {
        tmp = getchar();
        print_chr(tmp); 
//        for(int i = 0; i < 100000; i++);  
        if(tmp == 'q')
            return;
    }
}