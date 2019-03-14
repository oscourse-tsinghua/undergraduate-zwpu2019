module flash_test(	
	input clk,
	input resetn,
	input count,
	output reg [7:0] led,
	output [8:0] seg1,
	output [8:0] seg2

);

	reg num;
	wire [31:0] inst;
	reg [13:0] inst_addr;
	
	
	always @(posedge clk) begin
		num <= count;
		if(!resetn) begin
			led <= 8'b11111111;
			inst_addr <= 0;
		end
		else begin
			led <= inst[7:0];
			if(num > count) begin
				inst_addr = inst_addr + 4;
			end
		end
	end
	
	segment seg_inst(
		.seg_data_1(inst[31:28]),
		.seg_data_2(inst[27:24]),
		.segment_led_1(seg1),
		.segment_led_2(seg2)
	);

flash u0 (
		.clock                   (clk),                   //    clk.clk
		.reset_n                 (resetn),                 // nreset.reset_n
		.avmm_data_addr          (inst_addr),          //   data.address
		.avmm_data_read          (1'b1),          //       .read
		.avmm_data_writedata     (),     //       .writedata
		.avmm_data_write         (),         //       .write
		.avmm_data_readdata      (inst),      //       .readdata
		.avmm_data_waitrequest   (),   //       .waitrequest
		.avmm_data_readdatavalid (), //       .readdatavalid
		.avmm_data_burstcount    (),    //       .burstcount
		.avmm_csr_addr           (),           //    csr.address
		.avmm_csr_read           (),           //       .read
		.avmm_csr_writedata      (),      //       .writedata
		.avmm_csr_write          (),          //       .write
		.avmm_csr_readdata       ()        //       .readdata
	);

endmodule