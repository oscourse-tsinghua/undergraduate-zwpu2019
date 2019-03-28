	module pico_cyc10_top(
	input clk,
	input rst_n,
	
	input rx,
	output tx,

	output [7:0] led,
	output [11:0] seg
);

	wire [3:0] seg_value;
	wire tx_value;
	
	assign tx = tx_value;
	
		pico_cyc10_qys u0 (
		.clk_clk       (clk),       //   clk.clk
		.reset_reset_n (rst_n), // reset.reset_n
		.uart_rxd      (rx),      //  uart.rxd
		.uart_txd      (tx_value),      //      .txd
		.led_export    (led),    //   led.export
		.seg_export    (seg_value),    //   seg.export
		.trap_export   ()    //  trap.export
	);



	segment seg_inst(
		.seg_data_1(seg_value),
		.segment_led_1(seg)
	);
	
endmodule
