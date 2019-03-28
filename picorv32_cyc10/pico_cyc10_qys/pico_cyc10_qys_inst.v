	pico_cyc10_qys u0 (
		.clk_clk       (<connected-to-clk_clk>),       //   clk.clk
		.led_export    (<connected-to-led_export>),    //   led.export
		.reset_reset_n (<connected-to-reset_reset_n>), // reset.reset_n
		.seg_export    (<connected-to-seg_export>),    //   seg.export
		.trap_export   (<connected-to-trap_export>),   //  trap.export
		.uart_rxd      (<connected-to-uart_rxd>),      //  uart.rxd
		.uart_txd      (<connected-to-uart_txd>)       //      .txd
	);

