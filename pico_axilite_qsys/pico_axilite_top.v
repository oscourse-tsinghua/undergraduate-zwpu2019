module pico_axilite_top(
	input clk,
	input rst_n,
	input rx,
	output tx,
	output [7:0] led
);



	pico_qsys u0 (
		.clk_clk       (clk),       //   clk.clk
		.reset_reset_n (rst_n), // reset.reset_n
		.uart_rxd      (rx),      //  uart.rxd
		.uart_txd      (tx),       //      .txd
		.led_export		(led)
	);

endmodule
