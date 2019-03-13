	pico_qsys u0 (
		.clk_clk       (<connected-to-clk_clk>),       //   clk.clk
		.reset_reset_n (<connected-to-reset_reset_n>), // reset.reset_n
		.uart_rxd      (<connected-to-uart_rxd>),      //  uart.rxd
		.uart_txd      (<connected-to-uart_txd>),      //      .txd
		.led_export    (<connected-to-led_export>)     //   led.export
	);

