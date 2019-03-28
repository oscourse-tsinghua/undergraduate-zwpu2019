
module pico_cyc10_qys (
	clk_clk,
	led_export,
	reset_reset_n,
	seg_export,
	trap_export,
	uart_rxd,
	uart_txd);	

	input		clk_clk;
	output	[7:0]	led_export;
	input		reset_reset_n;
	output	[7:0]	seg_export;
	output		trap_export;
	input		uart_rxd;
	output		uart_txd;
endmodule
