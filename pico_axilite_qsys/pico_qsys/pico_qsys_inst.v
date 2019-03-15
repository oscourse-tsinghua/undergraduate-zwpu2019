	pico_qsys u0 (
		.clk_clk       (<connected-to-clk_clk>),       //   clk.clk
		.led_export    (<connected-to-led_export>),    //   led.export
		.reset_reset_n (<connected-to-reset_reset_n>), // reset.reset_n
		.uart_rxd      (<connected-to-uart_rxd>),      //  uart.rxd
		.uart_txd      (<connected-to-uart_txd>),      //      .txd
		.seg1_export   (<connected-to-seg1_export>),   //  seg1.export
		.seg2_export   (<connected-to-seg2_export>),   //  seg2.export
		.sw_export     (<connected-to-sw_export>)      //    sw.export
	);

