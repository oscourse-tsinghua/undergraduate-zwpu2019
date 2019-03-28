module segment
   (
    input  wire [3:0] seg_data_1,  //四位输入数据信号
    input  wire [3:0] seg_data_2,  //四位输入数据信号
    output wire [11:0] segment_led_1,  //数码管1，MSB~LSB = SEG,DP,G,F,E,D,C,B,A
    output wire [11:0] segment_led_2   //数码管2，MSB~LSB = SEG,DP,G,F,E,D,C,B,A
   );
   reg[11:0] seg [15:0];           //存储7段数码管译码数据
   initial 
	begin
		seg[0] = ~12'h3f;   //  0
		seg[1] = ~12'h06;   //  1
		seg[2] = ~12'h5b;   //  2
		seg[3] = ~12'h4f;   //  3
		seg[4] = ~12'h66;   //  4
		seg[5] = ~12'h6d;   //  5
		seg[6] = ~12'h7d;   //  6
		seg[7] = ~12'h07;   //  7
		seg[8] = ~12'h7f;   //  8
		seg[9] = ~12'h6f;   //  9
		seg[10]= ~12'h77;   //  A
		seg[11]= ~12'h7C;   //  B
		seg[12]= ~12'h39;   //  C
		seg[13]= ~12'h5e;   //  D
		seg[14]= ~12'h79;   //  E
		seg[15]= ~12'h71;   //  F
	end
   assign segment_led_1 = seg[seg_data_1];
   assign segment_led_2 = seg[seg_data_2];
  endmodule