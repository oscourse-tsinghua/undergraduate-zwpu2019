module rom_test (
	input clk,
	input resetn,
	input count,
	
	output reg [7:0] led,
	output [8:0] seg1,
	output [8:0] seg2
);

	wire [31:0] inst;
	reg [13:0] inst_addr;
	reg num;
	
	
	always @(posedge clk) begin
		num <= count;
		if(!resetn) begin
			led <= 8'b11111111;
			inst_addr <= 0;
		end
		else begin
			led <= ~inst_addr[9:2];
			if(num > count) begin
				inst_addr = inst_addr + 4;
			end
		end
	end
	
	segment seg_inst(
		.seg_data_1(inst[3:0]),  //四位输入数据信号
		.seg_data_2(inst[7:4]),  //四位输入数据信号
		.segment_led_1(seg1),  //数码管1，MSB~LSB = SEG,DP,G,F,E,D,C,B,A
    .	segment_led_2(seg2)   //数码管2，MSB~LSB = SEG,DP,G,F,E,D,C,B,A
   );
	
	rom rom_inst(
		.address(inst_addr[6:2]),
		.clock(clk),
		.q(inst)
	);
	
endmodule