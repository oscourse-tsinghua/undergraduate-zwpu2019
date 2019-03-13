`timescale 1ns/1ns

module pico_tb;


reg clk, rst;
wire rx, tx;

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
	.tx(tx)
);

endmodule