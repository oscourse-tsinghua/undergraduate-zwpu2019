#include"firmware.h"

void judge_cmd();
int strcmp();
void ls();
void segment();
void led();

char command[20];

char cmd_symbol[] = "z@zhuweipu >>> ";

int main() {
    print_str("\n\nBooting.......................................\n");
    print_logo();

    print_str(cmd_symbol);
    char tmp;
 
    int command_len = 0;
    
    while(1) {
        tmp = getchar();
        
        if(tmp == '\n') {
            print_chr('\r');
        }
        print_chr(tmp);
        command[command_len] = tmp;

        if(tmp == '\n') {
            command[command_len] = '\0';
//            print_str(command);
//            print_dec(command_len);
            judge_cmd();
            command_len = 0;
        }     
        else {
            command_len++;
 //           print_str("\n len = ");
 //           print_dec(command_len);
        }
            
    }
    return 0;
}

void judge_cmd() {
    // print_str("Command is: ");
    // print_str(command);
    // print_str("\n");


    if(strcmp(command,"ls") == 0) {
        ls();
    }
    else if(strcmp(command,"segment") == 0) {
        segment();
    }
    else if(strcmp(command,"led\0") == 0) {
        led();
    }
    else if(strcmp(command,"sieve\0") == 0) {
        sieve();
    }
    else if(strcmp(command,"stat\0") == 0) {
        stats();
    }
    else if(strcmp(command,"\0") == 0) {
        //do nothing
    }
    else {
        print_str("            command not found\n");   
    }

    print_str(cmd_symbol);   

    return; 
}

void ls(void) {
    print_str("Following commands are available.\n");

    print_str(" ls     segment      led    sieve        stat      \n");
}

void segment() {
    print_str("Please input the number to display (0~99)\n");
    char data[3] = "00";
    int index = 0;
    int num = 0;
    while(1) {
        data[index] = getchar();
        print_chr(data[index]);
        if(data[index] >= '0' && data[index] <= '9') {
            num *= 10;
            num += data[index] - '0';
            index++;
        }
        else {
            if(data[index] != '\n') {
                print_str("The format is error.");
                return;
            }
            break;
        }
    }

    if(data[index] == '\n') {
        *((volatile uint32_t*)0x04000000) = num / 10;
        *((volatile uint32_t*)0x04000010) = num % 10;
    }
    print_str("\n");
}

void led() {
    int i = 0;
    int j = 0;
    for(i = 0; i < 9; i++) {
        *((volatile uint32_t*)0x03000000) = 0xff >> i;
        for(j = 0; j <= 50000; j++);
    }
    print_str("LED is finished!\n");
}

int strcmp(const char* str1, const char* str2)
{
	int ret = 0;
	while(!(ret=*(unsigned char*)str1-*(unsigned char*)str2) && *str1)
	{
        // print_str("\nstr1:");
        // print_chr(*(unsigned char*)str1);
        // print_str("\nstr2:");
        // print_chr(*(unsigned char*)str1);
		str1++;
		str2++;
	}
 //   print_str("\nret = ");
 //   print_dec(ret);

	if (ret < 0)
	{
		return -1;
	}
	else if (ret > 0)
	{
		return 1;
	}
	return 0;
}
