
module pico_qsys (
	clk_clk,
	reset_reset_n,
	uart_rxd,
	uart_txd,
	led_export,
	sw_export,
	seg1_export,
	seg2_export,
	trap_export);	

	input		clk_clk;
	input		reset_reset_n;
	input		uart_rxd;
	output		uart_txd;
	output	[7:0]	led_export;
	input	[7:0]	sw_export;
	output	[7:0]	seg1_export;
	output	[7:0]	seg2_export;
	output		trap_export;
endmodule
