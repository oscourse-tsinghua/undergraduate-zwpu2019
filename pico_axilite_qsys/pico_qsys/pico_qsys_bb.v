
module pico_qsys (
	clk_clk,
	reset_reset_n,
	uart_rxd,
	uart_txd,
	led_export);	

	input		clk_clk;
	input		reset_reset_n;
	input		uart_rxd;
	output		uart_txd;
	output	[7:0]	led_export;
endmodule
