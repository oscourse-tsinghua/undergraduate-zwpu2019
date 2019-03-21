#include <stdio.h>


char buffer [3]; //用于存放转换好的十六进制字符串。由于只要支持2位整数，所以长度3即可
 
void inttohex(int aa)
{
    if(aa >= 256)
	aa = aa % 256;
    if (aa / 16 < 10)   //计算十位，并转换成字符 
        buffer[0] = aa / 16 + '0';
    else
        buffer[0] = aa / 16 - 10 + 'a';
    if (aa % 16 < 10)   //计算个位，并转换成字符
        buffer[1] = aa % 16 + '0';
    else
        buffer[1] = aa % 16 - 10 + 'a';
    buffer[2] = '\0';   //字符串结束标志
}



int main() {
    FILE *fpr, *fpw;
    fpr = fopen("hx8kdemo_fw.coe", "r");
    fpw = fopen("hx8kdemo_fw.hex", "w");

    int sum = 0;
    int prioty = 0;
    char ch=fgetc(fpr);
    while (ch != EOF) {
	if(ch >= '0' && ch <= '9') {
	    if(prioty % 2 == 0) {
		sum += (ch - '0')*16;
	    }
	    else 
		sum += ch - '0';
	    prioty++;
	}
	    
	else if (ch >= 'a' && ch <= 'f') {
	    if(prioty % 2 == 0) {
		sum += (ch - 'a' + 10) * 16;
	    }
	    else 
		sum += ch - 'a' + 10;
	    prioty++;
	}
	    
	else if (ch == '\n') {
            inttohex(256 - (sum % 256));
            fputc(buffer[0], fpw);
	    fputc(buffer[1], fpw); 
	    sum = 0;
	}
        fputc(ch, fpw);
	ch = fgetc(fpr);
    }
	
    fprintf(fpw,"%s\n", ":00000001FF");	
    fclose(fpr);
    fclose(fpw);
    return 0;
}

