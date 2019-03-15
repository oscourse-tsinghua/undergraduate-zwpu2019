`timescale 1ns/1ns

module pico_tb;


reg clk, rst;
wire rx, tx;
wire [7:0] led;
wire [8:0] seg1, seg2;

initial begin
	clk = 1;
	forever #10 clk = ~clk;
end

initial begin
	rst = 0;
	#100 rst = 1;
end

assign tx = 1;

pico_axilite_top uo(
	.clk(clk),
	.rst_n(rst),
	.rx(rx),
	.tx(tx),
	.led(led),
	.seg1(seg1),
	.seg2(seg2),
	.sw(4'b1111)
);


endmodule