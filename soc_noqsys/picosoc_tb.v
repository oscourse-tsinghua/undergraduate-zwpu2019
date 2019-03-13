`timescale 1ns / 1ps
module picosoc_tb;

reg clk, rst;
wire rx, tx;

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
	.ser_rx(tx)
);


endmodule