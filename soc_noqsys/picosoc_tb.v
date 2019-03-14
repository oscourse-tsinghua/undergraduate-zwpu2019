`timescale 1ns / 1ps
module picosoc_tb;

reg clk, rst;
wire rx, tx;
wire [7:0] led;
wire [8:0] seg1, seg2;

initial begin
	clk = 0;
	forever #10 clk = ~clk;
end

initial begin
	rst = 0;
	#100 rst = 1;
end

picosoc u0 (
	.clk(clk),
	.resetn(rst),

	.ser_tx(tx),
	.ser_rx(tx),
	
	.sw(4'b1111),
	.led(led),
	.seg1(seg1),
	.seg2(seg2)
);


endmodule