module rom_test (
	input clk,
	input resetn,
	input count,
	output reg [7:0] led,
	output reg [7:0] seg_led,
	output [3:0] seg_dig
);

	wire [31:0] inst;
	reg [13:0] inst_addr;

/*
	always @(posedge clk) begin
		if(!resetn) begin
			inst_addr <= 0;
		end
		else begin
			inst_addr <= inst_addr + 4;
		end
	end
*/	
	reg num;
	
	always @(posedge clk) begin
		num <= count;
		if(!resetn) begin
			led <= 8'b11111111;
			inst_addr <= 0;
		end
		else begin
			led <= inst_addr[9:2];
			if(num > count) begin
				inst_addr = inst_addr + 4;
			end
		end
	end
	
	assign seg_dig = 4'b1111;
	
	always @(*) begin
		case(inst[7:4])
				4'h0 : begin seg_led <= ~8'h3f;  	end
				4'h1 : begin seg_led <= ~8'h06;	 	end
				4'h2 : begin seg_led <= ~8'h5b;		end
				4'h3 : begin seg_led <= ~8'h4f;		end	
				4'h4 : begin seg_led <= ~8'h66;		end
				4'h5 : begin seg_led <= ~8'h6d;		end
				4'h6 : begin seg_led <= ~8'h7d;		end
				4'h7 : begin seg_led <= ~8'h07;		end		
				4'h8 : begin seg_led <= ~8'h7f; 	end
				4'h9 : begin seg_led <= ~8'h6f; 	end
				4'ha : begin seg_led <= ~8'h77;		end
				4'hb : begin seg_led <= ~8'h7C;		end
				4'hc : begin seg_led <= ~8'h39;		end
				4'hd : begin seg_led <= ~8'h5e;		end
				4'he : begin seg_led <= ~8'h79;		end
				4'hf : begin seg_led <= ~8'h71;		end
			endcase
	end
	
	rom rom_inst(
		.address(inst_addr[13:2]),
		.clock(clk),
		.q(inst)
	);
	
endmodule