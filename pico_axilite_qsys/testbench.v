// This is free and unencumbered software released into the public domain.
//
// Anyone is free to copy, modify, publish, use, compile, sell, or
// distribute this software, either in source code form or as a compiled
// binary, for any purpose, commercial or non-commercial, and by any
// means.

`timescale 1 ns / 1 ps


module testbench #(
	parameter AXI_TEST = 0,
	parameter VERBOSE = 0
);
	reg clk = 1;
	reg resetn = 0;
	wire rx, tx;

	always #5 clk = ~clk;

	initial begin
		repeat (100) @(posedge clk);
		resetn <= 1;
	end

	
	pico_axilite_top soc(
		.clk(clk),
		.rst_n(resetn),
		.rx(rx),
		.tx(tx)
	);
//
//	always @(negedge clk) begin
//		if (soc.u0.pico_axilite_0_altera_axi4lite_master_awaddr == 32'h1000_0000) begin
//			$write("%c", );
//		end
//	end

endmodule