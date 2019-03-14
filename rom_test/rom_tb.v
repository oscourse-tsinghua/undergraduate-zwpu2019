`timescale 1ns / 1ps
module rom_tb;

reg clk, rst;
wire [7:0] led;

initial begin
	clk = 0;
	forever #10 clk = ~clk;
end

initial begin
	rst = 0;
	#1000 rst = 1;
end

rom_test u0 (
	.clk(clk),
	.resetn(rst),

	.led(led)
);


endmodule