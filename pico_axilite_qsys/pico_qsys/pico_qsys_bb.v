
module pico_qsys (
	clk_clk,
	led_export,
	reset_reset_n,
	seg1_export,
	seg2_export,
	sw_export,
	uart_rxd,
	uart_txd);	

	input		clk_clk;
	output	[7:0]	led_export;
	input		reset_reset_n;
	output	[7:0]	seg1_export;
	output	[7:0]	seg2_export;
	input	[7:0]	sw_export;
	input		uart_rxd;
	output		uart_txd;
endmodule
