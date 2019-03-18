/*
 *  PicoSoC - A simple example SoC using PicoRV32
 *
 *  Copyright (C) 2017  Clifford Wolf <clifford@clifford.at>
 *
 *  Permission to use, copy, modify, and/or distribute this software for any
 *  purpose with or without fee is hereby granted, provided that the above
 *  copyright notice and this permission notice appear in all copies.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 *  WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 *  MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 *  ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 *  WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 *  ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 *  OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *
 */

module picosoc (
	input clk,
	input resetn,

	output ser_tx,
	input  ser_rx,
	
	input [3:0] sw,
	
	output [7:0] led,
	output [8:0] seg1,
	output [8:0] seg2,
	
	output clk_out
);

	parameter [0:0] BARREL_SHIFTER = 1;
	parameter [0:0] ENABLE_MULDIV = 1;
	parameter [0:0] ENABLE_COMPRESSED = 1;
	parameter [0:0] ENABLE_COUNTERS = 1;
	parameter [0:0] ENABLE_IRQ_QREGS = 0;

	wire        clk_50M;
	wire        locked;
	
	wire        mem_valid;
	wire        mem_instr;
	wire        mem_ready;
	wire [31:0] mem_addr;
	wire [31:0] mem_wdata;
	wire [ 3:0] mem_wstrb;
	wire [31:0] mem_rdata;
	
	wire [31:0] irq = 0;

	wire [31:0] rom_rdata;
	
	wire ram_wren = (mem_valid && !mem_ready && (mem_addr >= 32'h0000_4000) && (mem_addr < 32'h0000_8000) ) ? mem_wstrb : 4'b0;
	wire [31:0] ram_rdata;
	
	wire        simpleuart_reg_div_sel = mem_valid && (mem_addr == 32'h 0200_0004);
	wire [31:0] simpleuart_reg_div_do;

	wire        simpleuart_reg_dat_sel = mem_valid && (mem_addr == 32'h 0200_0008);
	wire [31:0] simpleuart_reg_dat_do;
	wire        simpleuart_reg_dat_wait;

	reg [31:0] gpio_reg;
	reg [31:0] seg_reg;
	
	reg ram_ready;
	reg rom_ready;
	reg gpio_ready;
	reg seg_ready;
	
	
	assign mem_ready =  rom_ready || ram_ready || simpleuart_reg_div_sel || (simpleuart_reg_dat_sel && !simpleuart_reg_dat_wait) || gpio_ready || seg_ready;

	assign mem_rdata = rom_ready ? rom_rdata :
							 ram_ready ? ram_rdata :
							 simpleuart_reg_div_sel ? simpleuart_reg_div_do :
							 simpleuart_reg_dat_sel ? simpleuart_reg_dat_do : 
							 gpio_ready ? gpio_reg :
							 seg_ready ? seg_reg : 32'h 0000_0000;
	
	assign clk_out = clk_50M;
	
	pll pll_inst (
		.areset		(!resetn),
		.inclk0		(clk),
		.c0			(clk_50M),
		.locked		(locked)
	);	
		
	picorv32 #(
//		.STACKADDR(STACKADDR),
//		.PROGADDR_RESET(PROGADDR_RESET),
//		.PROGADDR_IRQ(PROGADDR_IRQ),
		.BARREL_SHIFTER(BARREL_SHIFTER),
		.COMPRESSED_ISA(ENABLE_COMPRESSED),
		.ENABLE_COUNTERS(ENABLE_COUNTERS),
		.ENABLE_MUL(ENABLE_MULDIV),
		.ENABLE_DIV(ENABLE_MULDIV),
		.ENABLE_IRQ(1),
		.ENABLE_IRQ_QREGS(ENABLE_IRQ_QREGS)
	) cpu (
		.clk         (clk_50M        ),
		.resetn      (locked     ),
		.mem_valid   (mem_valid  ),
		.mem_instr   (mem_instr  ),
		.mem_ready   (mem_ready  ),
		.mem_addr    (mem_addr   ),
		.mem_wdata   (mem_wdata  ),
		.mem_wstrb   (mem_wstrb  ),
		.mem_rdata   (mem_rdata  ),
		.irq         (irq        )
	);

	always @(posedge clk_50M)
		rom_ready <= mem_valid && !mem_ready && mem_addr >= 32'h0000_0000 && mem_addr < 32'h0000_4000;
		
	rom rom_inst (
		.address(mem_addr[13:2]),				//16kB
		.clock(clk_50M),
		.q(rom_rdata)
	);
	

	always @(posedge clk_50M)
		ram_ready <= mem_valid && !mem_ready && mem_addr >= 32'h0000_4000 && mem_addr < 32'h0000_8000;
		
	ram ram_inst (
		.address(mem_addr[13:2]),				//16kB
		.clock(clk_50M),
		.data(mem_wdata),
		.wren(ram_wren),
		.q(ram_rdata)
	);
	
	
	simpleuart simpleuart (
		.clk         (clk_50M         ),
		.resetn      (locked      ),

		.ser_tx      (ser_tx      ),
		.ser_rx      (ser_rx      ),

		.reg_div_we  (simpleuart_reg_div_sel ? mem_wstrb : 4'b 0000),
		.reg_div_di  (mem_wdata),
		.reg_div_do  (simpleuart_reg_div_do),

		.reg_dat_we  (simpleuart_reg_dat_sel ? mem_wstrb[0] : 1'b 0),
		.reg_dat_re  (simpleuart_reg_dat_sel && !mem_wstrb),
		.reg_dat_di  (mem_wdata),
		.reg_dat_do  (simpleuart_reg_dat_do),
		.reg_dat_wait(simpleuart_reg_dat_wait)
	);
	
	always @(posedge clk_50M)
		gpio_ready <= mem_valid && !mem_ready && mem_addr == 32'h0300_0000;

	always @(posedge clk_50M) begin
		if(!locked) 
			gpio_reg <= 8'b11111111;
		else if (mem_valid && mem_addr == 32'h0300_0000) begin
			if(mem_wstrb[0]) gpio_reg[7:0] <= mem_wdata[7:0];
			if(mem_wstrb[1]) gpio_reg[15:8] <= mem_wdata[15:8];
			if(mem_wstrb[2]) gpio_reg[23:16] <= mem_wdata[23:16];
			//if(mem_wstrb[3]) gpio_reg[31:24] <= mem_wdata[31:24];
			gpio_reg[31:24] <= {3'b000, sw[3:0]};
		end
	end
	
	
	assign led = gpio_reg[7:0];
	
	always @(posedge clk_50M) begin
		seg_ready <= mem_valid && !mem_ready && mem_addr == 32'h0300_0004;
	end
	
	always @(posedge clk_50M) begin
		if(!locked) begin
			seg_reg <= 0;
		end
		else if(mem_valid && mem_addr == 32'h0300_0004) begin
			if(mem_wstrb[0]) seg_reg[7:0] <= mem_wdata[7:0];
			if(mem_wstrb[1]) seg_reg[15:8] <= mem_wdata[15:8];
			if(mem_wstrb[2]) seg_reg[23:16] <= mem_wdata[23:16];
			if(mem_wstrb[3]) seg_reg[31:24] <= mem_wdata[31:24];
		end
	end
	
	segment seg_inst(
		.seg_data_1(seg_reg[3:0]),  //四位输入数据信号
		.seg_data_2(seg_reg[11:8]),  //四位输入数据信号
		.segment_led_1(seg1),  //数码管1，MSB~LSB = SEG,DP,G,F,E,D,C,B,A
		.segment_led_2(seg2)   //数码管2，MSB~LSB = SEG,DP,G,F,E,D,C,B,A
   );
	
endmodule
