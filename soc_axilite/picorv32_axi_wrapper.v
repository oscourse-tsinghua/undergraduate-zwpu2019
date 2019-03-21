module picorv32_axi_wrapper # (
	parameter [ 0:0] ENABLE_COUNTERS = 1,
	parameter [ 0:0] ENABLE_COUNTERS64 = 1,
	parameter [ 0:0] ENABLE_REGS_16_31 = 1,
	parameter [ 0:0] ENABLE_REGS_DUALPORT = 1,
	parameter [ 0:0] TWO_STAGE_SHIFT = 1,
	parameter [ 0:0] BARREL_SHIFTER = 0,
	parameter [ 0:0] TWO_CYCLE_COMPARE = 0,
	parameter [ 0:0] TWO_CYCLE_ALU = 0,
	parameter [ 0:0] COMPRESSED_ISA = 0,
	parameter [ 0:0] CATCH_MISALIGN = 1,
	parameter [ 0:0] CATCH_ILLINSN = 1,
	parameter [ 0:0] ENABLE_PCPI = 0,
	parameter [ 0:0] ENABLE_MUL = 0,
	parameter [ 0:0] ENABLE_FAST_MUL = 0,
	parameter [ 0:0] ENABLE_DIV = 0,
	parameter [ 0:0] ENABLE_IRQ = 0,
	parameter [ 0:0] ENABLE_IRQ_QREGS = 1,
	parameter [ 0:0] ENABLE_IRQ_TIMER = 1,
	parameter [ 0:0] ENABLE_TRACE = 0,
	parameter [ 0:0] REGS_INIT_ZERO = 0,
	parameter [31:0] MASKED_IRQ = 32'h 0000_0000,
	parameter [31:0] LATCHED_IRQ = 32'h ffff_ffff,
	parameter [31:0] PROGADDR_RESET = 32'h 0000_0000,
	parameter [31:0] PROGADDR_IRQ = 32'h 0000_0010,
	parameter [31:0] STACKADDR = 32'h ffff_ffff
) (
	input clk, rsi_resetn,
	output coe_trap,

	// AXI4-lite master memory interface

	output        axm_awvalid,
	input         axm_awready,
	output [31:0] axm_awaddr,
	output [ 2:0] axm_awprot,

	output        axm_wvalid,
	input         axm_wready,
	output [31:0] axm_wdata,
	output [ 3:0] axm_wstrb,

	input         axm_bvalid,
	input  [ 1:0] axm_bresp,
	output        axm_bready,

	output        axm_arvalid,
	input         axm_arready,
	output [31:0] axm_araddr,
	output [ 2:0] axm_arprot,

	input         axm_rvalid,
	input  [ 1:0] axm_rresp,
	output        axm_rready,
	input  [31:0] axm_rdata,

	// IRQ interface
	input  [31:0] inr_irq

	// Trace Interface
//	output        coe_trace_valid,
//	output [35:0] coe_trace_data
);
	
	picorv32_axi #(
		.ENABLE_COUNTERS     (ENABLE_COUNTERS     ),
		.ENABLE_COUNTERS64   (ENABLE_COUNTERS64   ),
		.ENABLE_REGS_16_31   (ENABLE_REGS_16_31   ),
		.ENABLE_REGS_DUALPORT(ENABLE_REGS_DUALPORT),
		.TWO_STAGE_SHIFT     (TWO_STAGE_SHIFT     ),
		.BARREL_SHIFTER      (BARREL_SHIFTER      ),
		.TWO_CYCLE_COMPARE   (TWO_CYCLE_COMPARE   ),
		.TWO_CYCLE_ALU       (TWO_CYCLE_ALU       ),
		.COMPRESSED_ISA      (COMPRESSED_ISA      ),
		.CATCH_MISALIGN      (CATCH_MISALIGN      ),
		.CATCH_ILLINSN       (CATCH_ILLINSN       ),
		.ENABLE_PCPI         (ENABLE_PCPI         ),
		.ENABLE_MUL          (ENABLE_MUL          ),
		.ENABLE_FAST_MUL     (ENABLE_FAST_MUL     ),
		.ENABLE_DIV          (ENABLE_DIV          ),
		.ENABLE_IRQ          (ENABLE_IRQ          ),
		.ENABLE_IRQ_QREGS    (ENABLE_IRQ_QREGS    ),
		.ENABLE_IRQ_TIMER    (ENABLE_IRQ_TIMER    ),
		.ENABLE_TRACE        (ENABLE_TRACE        ),
		.REGS_INIT_ZERO      (REGS_INIT_ZERO      ),
		.MASKED_IRQ          (MASKED_IRQ          ),
		.LATCHED_IRQ         (LATCHED_IRQ         ),
		.PROGADDR_RESET      (PROGADDR_RESET      ),
		.PROGADDR_IRQ        (PROGADDR_IRQ        ),
		.STACKADDR           (STACKADDR           )
	) uut (
		.clk            (clk            ),
		.resetn         (rsi_resetn         ),
		.trap           (coe_trap           ),
		.mem_axi_awvalid(axm_awvalid),
		.mem_axi_awready(axm_awready),
		.mem_axi_awaddr (axm_awaddr ),
		.mem_axi_awprot (axm_awprot ),
		.mem_axi_wvalid (axm_wvalid ),
		.mem_axi_wready (axm_wready ),
		.mem_axi_wdata  (axm_wdata  ),
		.mem_axi_wstrb  (axm_wstrb  ),
		.mem_axi_bvalid (axm_bvalid ),
		.mem_axi_bready (axm_bready ),
		.mem_axi_arvalid(axm_arvalid),
		.mem_axi_arready(axm_arready),
		.mem_axi_araddr (axm_araddr ),
		.mem_axi_arprot (axm_arprot ),
		.mem_axi_rvalid (axm_rvalid ),
		.mem_axi_rready (axm_rready ),
		.mem_axi_rdata  (axm_rdata  ),
		.irq            (ins_irq            )
		
//		.trace_valid    (coe_trace_valid    ),
//		.trace_data     (coe_trace_data     )
	);
	
	
	
endmodule
