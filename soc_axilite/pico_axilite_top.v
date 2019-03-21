module pico_axilite_top(
	input clk,
	input rst_n,
	
	input rx,
	output tx,
	
	input [3:0] sw,
	output [7:0] led,
	output [8:0] seg1,
	output [8:0] seg2
);

	wire [3:0] seg1_value, seg2_value;
	wire tx_value;
	
	assign tx = tx_value;
	
	pico_qsys u0 (
		.clk_clk       (clk),       //   clk.clk
		.reset_reset_n (rst_n), // reset.reset_n
		.uart_rxd      (rx),      //  uart.rxd
		.uart_txd      (tx_value),       //      .txd
		.led_export		(led),
		.seg1_export	(seg1_value),
		.seg2_export	(seg2_value),
		.sw_export		({4'b0000, sw})
	);

	segment seg_inst(
		.seg_data_1(seg1_value),
		.seg_data_2(seg2_value),
		.segment_led_1(seg1),
		.segment_led_2(seg2)
	);
	
endmodule
