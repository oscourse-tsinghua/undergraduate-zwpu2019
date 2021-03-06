// pico_qsys.v

// Generated using ACDS version 16.0 211

`timescale 1 ps / 1 ps
module pico_qsys (
		input  wire       clk_clk,       //   clk.clk
		output wire [7:0] led_export,    //   led.export
		input  wire       reset_reset_n, // reset.reset_n
		output wire [7:0] seg1_export,   //  seg1.export
		output wire [7:0] seg2_export,   //  seg2.export
		input  wire [7:0] sw_export,     //    sw.export
		input  wire       uart_rxd,      //  uart.rxd
		output wire       uart_txd       //      .txd
	);

	wire  [31:0] pico_axilite_0_altera_axi4lite_master_awaddr;  // pico_axilite_0:axm_awaddr -> mm_interconnect_0:pico_axilite_0_altera_axi4lite_master_awaddr
	wire   [1:0] pico_axilite_0_altera_axi4lite_master_bresp;   // mm_interconnect_0:pico_axilite_0_altera_axi4lite_master_bresp -> pico_axilite_0:axm_bresp
	wire         pico_axilite_0_altera_axi4lite_master_arready; // mm_interconnect_0:pico_axilite_0_altera_axi4lite_master_arready -> pico_axilite_0:axm_arready
	wire  [31:0] pico_axilite_0_altera_axi4lite_master_rdata;   // mm_interconnect_0:pico_axilite_0_altera_axi4lite_master_rdata -> pico_axilite_0:axm_rdata
	wire         pico_axilite_0_altera_axi4lite_master_wready;  // mm_interconnect_0:pico_axilite_0_altera_axi4lite_master_wready -> pico_axilite_0:axm_wready
	wire   [3:0] pico_axilite_0_altera_axi4lite_master_wstrb;   // pico_axilite_0:axm_wstrb -> mm_interconnect_0:pico_axilite_0_altera_axi4lite_master_wstrb
	wire         pico_axilite_0_altera_axi4lite_master_awready; // mm_interconnect_0:pico_axilite_0_altera_axi4lite_master_awready -> pico_axilite_0:axm_awready
	wire         pico_axilite_0_altera_axi4lite_master_rready;  // pico_axilite_0:axm_rready -> mm_interconnect_0:pico_axilite_0_altera_axi4lite_master_rready
	wire         pico_axilite_0_altera_axi4lite_master_bready;  // pico_axilite_0:axm_bready -> mm_interconnect_0:pico_axilite_0_altera_axi4lite_master_bready
	wire         pico_axilite_0_altera_axi4lite_master_wvalid;  // pico_axilite_0:axm_wvalid -> mm_interconnect_0:pico_axilite_0_altera_axi4lite_master_wvalid
	wire  [31:0] pico_axilite_0_altera_axi4lite_master_araddr;  // pico_axilite_0:axm_araddr -> mm_interconnect_0:pico_axilite_0_altera_axi4lite_master_araddr
	wire   [2:0] pico_axilite_0_altera_axi4lite_master_arprot;  // pico_axilite_0:axm_arprot -> mm_interconnect_0:pico_axilite_0_altera_axi4lite_master_arprot
	wire   [1:0] pico_axilite_0_altera_axi4lite_master_rresp;   // mm_interconnect_0:pico_axilite_0_altera_axi4lite_master_rresp -> pico_axilite_0:axm_rresp
	wire   [2:0] pico_axilite_0_altera_axi4lite_master_awprot;  // pico_axilite_0:axm_awprot -> mm_interconnect_0:pico_axilite_0_altera_axi4lite_master_awprot
	wire  [31:0] pico_axilite_0_altera_axi4lite_master_wdata;   // pico_axilite_0:axm_wdata -> mm_interconnect_0:pico_axilite_0_altera_axi4lite_master_wdata
	wire         pico_axilite_0_altera_axi4lite_master_arvalid; // pico_axilite_0:axm_arvalid -> mm_interconnect_0:pico_axilite_0_altera_axi4lite_master_arvalid
	wire         pico_axilite_0_altera_axi4lite_master_bvalid;  // mm_interconnect_0:pico_axilite_0_altera_axi4lite_master_bvalid -> pico_axilite_0:axm_bvalid
	wire         pico_axilite_0_altera_axi4lite_master_awvalid; // pico_axilite_0:axm_awvalid -> mm_interconnect_0:pico_axilite_0_altera_axi4lite_master_awvalid
	wire         pico_axilite_0_altera_axi4lite_master_rvalid;  // mm_interconnect_0:pico_axilite_0_altera_axi4lite_master_rvalid -> pico_axilite_0:axm_rvalid
	wire         mm_interconnect_0_ram_s1_chipselect;           // mm_interconnect_0:RAM_s1_chipselect -> RAM:chipselect
	wire  [31:0] mm_interconnect_0_ram_s1_readdata;             // RAM:readdata -> mm_interconnect_0:RAM_s1_readdata
	wire  [11:0] mm_interconnect_0_ram_s1_address;              // mm_interconnect_0:RAM_s1_address -> RAM:address
	wire   [3:0] mm_interconnect_0_ram_s1_byteenable;           // mm_interconnect_0:RAM_s1_byteenable -> RAM:byteenable
	wire         mm_interconnect_0_ram_s1_write;                // mm_interconnect_0:RAM_s1_write -> RAM:write
	wire  [31:0] mm_interconnect_0_ram_s1_writedata;            // mm_interconnect_0:RAM_s1_writedata -> RAM:writedata
	wire         mm_interconnect_0_ram_s1_clken;                // mm_interconnect_0:RAM_s1_clken -> RAM:clken
	wire         mm_interconnect_0_uart_0_s1_chipselect;        // mm_interconnect_0:uart_0_s1_chipselect -> uart_0:chipselect
	wire  [15:0] mm_interconnect_0_uart_0_s1_readdata;          // uart_0:readdata -> mm_interconnect_0:uart_0_s1_readdata
	wire   [2:0] mm_interconnect_0_uart_0_s1_address;           // mm_interconnect_0:uart_0_s1_address -> uart_0:address
	wire         mm_interconnect_0_uart_0_s1_read;              // mm_interconnect_0:uart_0_s1_read -> uart_0:read_n
	wire         mm_interconnect_0_uart_0_s1_begintransfer;     // mm_interconnect_0:uart_0_s1_begintransfer -> uart_0:begintransfer
	wire         mm_interconnect_0_uart_0_s1_write;             // mm_interconnect_0:uart_0_s1_write -> uart_0:write_n
	wire  [15:0] mm_interconnect_0_uart_0_s1_writedata;         // mm_interconnect_0:uart_0_s1_writedata -> uart_0:writedata
	wire         mm_interconnect_0_led_s1_chipselect;           // mm_interconnect_0:led_s1_chipselect -> led:chipselect
	wire  [31:0] mm_interconnect_0_led_s1_readdata;             // led:readdata -> mm_interconnect_0:led_s1_readdata
	wire   [1:0] mm_interconnect_0_led_s1_address;              // mm_interconnect_0:led_s1_address -> led:address
	wire         mm_interconnect_0_led_s1_write;                // mm_interconnect_0:led_s1_write -> led:write_n
	wire  [31:0] mm_interconnect_0_led_s1_writedata;            // mm_interconnect_0:led_s1_writedata -> led:writedata
	wire         mm_interconnect_0_rom_s1_chipselect;           // mm_interconnect_0:ROM_s1_chipselect -> ROM:chipselect
	wire  [31:0] mm_interconnect_0_rom_s1_readdata;             // ROM:readdata -> mm_interconnect_0:ROM_s1_readdata
	wire         mm_interconnect_0_rom_s1_debugaccess;          // mm_interconnect_0:ROM_s1_debugaccess -> ROM:debugaccess
	wire  [11:0] mm_interconnect_0_rom_s1_address;              // mm_interconnect_0:ROM_s1_address -> ROM:address
	wire   [3:0] mm_interconnect_0_rom_s1_byteenable;           // mm_interconnect_0:ROM_s1_byteenable -> ROM:byteenable
	wire         mm_interconnect_0_rom_s1_write;                // mm_interconnect_0:ROM_s1_write -> ROM:write
	wire  [31:0] mm_interconnect_0_rom_s1_writedata;            // mm_interconnect_0:ROM_s1_writedata -> ROM:writedata
	wire         mm_interconnect_0_rom_s1_clken;                // mm_interconnect_0:ROM_s1_clken -> ROM:clken
	wire         mm_interconnect_0_seg1_s1_chipselect;          // mm_interconnect_0:seg1_s1_chipselect -> seg1:chipselect
	wire  [31:0] mm_interconnect_0_seg1_s1_readdata;            // seg1:readdata -> mm_interconnect_0:seg1_s1_readdata
	wire   [1:0] mm_interconnect_0_seg1_s1_address;             // mm_interconnect_0:seg1_s1_address -> seg1:address
	wire         mm_interconnect_0_seg1_s1_write;               // mm_interconnect_0:seg1_s1_write -> seg1:write_n
	wire  [31:0] mm_interconnect_0_seg1_s1_writedata;           // mm_interconnect_0:seg1_s1_writedata -> seg1:writedata
	wire         mm_interconnect_0_seg2_s1_chipselect;          // mm_interconnect_0:seg2_s1_chipselect -> seg2:chipselect
	wire  [31:0] mm_interconnect_0_seg2_s1_readdata;            // seg2:readdata -> mm_interconnect_0:seg2_s1_readdata
	wire   [1:0] mm_interconnect_0_seg2_s1_address;             // mm_interconnect_0:seg2_s1_address -> seg2:address
	wire         mm_interconnect_0_seg2_s1_write;               // mm_interconnect_0:seg2_s1_write -> seg2:write_n
	wire  [31:0] mm_interconnect_0_seg2_s1_writedata;           // mm_interconnect_0:seg2_s1_writedata -> seg2:writedata
	wire  [31:0] mm_interconnect_0_sw_s1_readdata;              // sw:readdata -> mm_interconnect_0:sw_s1_readdata
	wire   [1:0] mm_interconnect_0_sw_s1_address;               // mm_interconnect_0:sw_s1_address -> sw:address
	wire         irq_mapper_receiver0_irq;                      // uart_0:irq -> irq_mapper:receiver0_irq
	wire  [31:0] pico_axilite_0_interrupt_receiver_0_irq;       // irq_mapper:sender_irq -> pico_axilite_0:inr_irq
	wire         rst_controller_reset_out_reset;                // rst_controller:reset_out -> [RAM:reset, ROM:reset, irq_mapper:reset, led:reset_n, mm_interconnect_0:pico_axilite_0_reset_reset_bridge_in_reset_reset, pico_axilite_0:rsi_resetn, rst_translator:in_reset, seg1:reset_n, seg2:reset_n, sw:reset_n, uart_0:reset_n]
	wire         rst_controller_reset_out_reset_req;            // rst_controller:reset_req -> [RAM:reset_req, ROM:reset_req, rst_translator:reset_req_in]

	pico_qsys_RAM ram (
		.clk        (clk_clk),                             //   clk1.clk
		.address    (mm_interconnect_0_ram_s1_address),    //     s1.address
		.clken      (mm_interconnect_0_ram_s1_clken),      //       .clken
		.chipselect (mm_interconnect_0_ram_s1_chipselect), //       .chipselect
		.write      (mm_interconnect_0_ram_s1_write),      //       .write
		.readdata   (mm_interconnect_0_ram_s1_readdata),   //       .readdata
		.writedata  (mm_interconnect_0_ram_s1_writedata),  //       .writedata
		.byteenable (mm_interconnect_0_ram_s1_byteenable), //       .byteenable
		.reset      (rst_controller_reset_out_reset),      // reset1.reset
		.reset_req  (rst_controller_reset_out_reset_req)   //       .reset_req
	);

	pico_qsys_ROM rom (
		.clk         (clk_clk),                              //   clk1.clk
		.address     (mm_interconnect_0_rom_s1_address),     //     s1.address
		.debugaccess (mm_interconnect_0_rom_s1_debugaccess), //       .debugaccess
		.clken       (mm_interconnect_0_rom_s1_clken),       //       .clken
		.chipselect  (mm_interconnect_0_rom_s1_chipselect),  //       .chipselect
		.write       (mm_interconnect_0_rom_s1_write),       //       .write
		.readdata    (mm_interconnect_0_rom_s1_readdata),    //       .readdata
		.writedata   (mm_interconnect_0_rom_s1_writedata),   //       .writedata
		.byteenable  (mm_interconnect_0_rom_s1_byteenable),  //       .byteenable
		.reset       (rst_controller_reset_out_reset),       // reset1.reset
		.reset_req   (rst_controller_reset_out_reset_req)    //       .reset_req
	);

	pico_qsys_led led (
		.clk        (clk_clk),                             //                 clk.clk
		.reset_n    (~rst_controller_reset_out_reset),     //               reset.reset_n
		.address    (mm_interconnect_0_led_s1_address),    //                  s1.address
		.write_n    (~mm_interconnect_0_led_s1_write),     //                    .write_n
		.writedata  (mm_interconnect_0_led_s1_writedata),  //                    .writedata
		.chipselect (mm_interconnect_0_led_s1_chipselect), //                    .chipselect
		.readdata   (mm_interconnect_0_led_s1_readdata),   //                    .readdata
		.out_port   (led_export)                           // external_connection.export
	);

	picorv32_axi_wrapper #(
		.ENABLE_COUNTERS      (2'b01),
		.ENABLE_COUNTERS64    (2'b01),
		.ENABLE_REGS_16_31    (2'b01),
		.ENABLE_REGS_DUALPORT (2'b01),
		.TWO_STAGE_SHIFT      (2'b01),
		.BARREL_SHIFTER       (2'b00),
		.TWO_CYCLE_COMPARE    (2'b00),
		.TWO_CYCLE_ALU        (2'b00),
		.COMPRESSED_ISA       (2'b00),
		.CATCH_MISALIGN       (2'b01),
		.CATCH_ILLINSN        (2'b01),
		.ENABLE_PCPI          (2'b00),
		.ENABLE_MUL           (2'b00),
		.ENABLE_FAST_MUL      (2'b00),
		.ENABLE_DIV           (2'b00),
		.ENABLE_IRQ           (2'b00),
		.ENABLE_IRQ_QREGS     (2'b01),
		.ENABLE_IRQ_TIMER     (2'b01),
		.ENABLE_TRACE         (2'b00),
		.REGS_INIT_ZERO       (2'b00),
		.MASKED_IRQ           (34'b0000000000000000000000000000000000),
		.LATCHED_IRQ          (34'b0011111111111111111111111111111111),
		.PROGADDR_RESET       (34'b0000000000000000000000000000000000),
		.PROGADDR_IRQ         (34'b0000000000000000000000000000010000),
		.STACKADDR            (34'b0011111111111111111111111111111111)
	) pico_axilite_0 (
		.clk         (clk_clk),                                       //                  clock.clk
		.rsi_resetn  (~rst_controller_reset_out_reset),               //                  reset.reset_n
		.coe_trap    (),                                              //          conduit_end_0.export
		.axm_awvalid (pico_axilite_0_altera_axi4lite_master_awvalid), // altera_axi4lite_master.awvalid
		.axm_awready (pico_axilite_0_altera_axi4lite_master_awready), //                       .awready
		.axm_awaddr  (pico_axilite_0_altera_axi4lite_master_awaddr),  //                       .awaddr
		.axm_awprot  (pico_axilite_0_altera_axi4lite_master_awprot),  //                       .awprot
		.axm_wvalid  (pico_axilite_0_altera_axi4lite_master_wvalid),  //                       .wvalid
		.axm_wready  (pico_axilite_0_altera_axi4lite_master_wready),  //                       .wready
		.axm_wdata   (pico_axilite_0_altera_axi4lite_master_wdata),   //                       .wdata
		.axm_wstrb   (pico_axilite_0_altera_axi4lite_master_wstrb),   //                       .wstrb
		.axm_bvalid  (pico_axilite_0_altera_axi4lite_master_bvalid),  //                       .bvalid
		.axm_bresp   (pico_axilite_0_altera_axi4lite_master_bresp),   //                       .bresp
		.axm_bready  (pico_axilite_0_altera_axi4lite_master_bready),  //                       .bready
		.axm_arvalid (pico_axilite_0_altera_axi4lite_master_arvalid), //                       .arvalid
		.axm_arready (pico_axilite_0_altera_axi4lite_master_arready), //                       .arready
		.axm_araddr  (pico_axilite_0_altera_axi4lite_master_araddr),  //                       .araddr
		.axm_arprot  (pico_axilite_0_altera_axi4lite_master_arprot),  //                       .arprot
		.axm_rvalid  (pico_axilite_0_altera_axi4lite_master_rvalid),  //                       .rvalid
		.axm_rresp   (pico_axilite_0_altera_axi4lite_master_rresp),   //                       .rresp
		.axm_rready  (pico_axilite_0_altera_axi4lite_master_rready),  //                       .rready
		.axm_rdata   (pico_axilite_0_altera_axi4lite_master_rdata),   //                       .rdata
		.inr_irq     (pico_axilite_0_interrupt_receiver_0_irq)        //   interrupt_receiver_0.irq
	);

	pico_qsys_seg1 seg1 (
		.clk        (clk_clk),                              //                 clk.clk
		.reset_n    (~rst_controller_reset_out_reset),      //               reset.reset_n
		.address    (mm_interconnect_0_seg1_s1_address),    //                  s1.address
		.write_n    (~mm_interconnect_0_seg1_s1_write),     //                    .write_n
		.writedata  (mm_interconnect_0_seg1_s1_writedata),  //                    .writedata
		.chipselect (mm_interconnect_0_seg1_s1_chipselect), //                    .chipselect
		.readdata   (mm_interconnect_0_seg1_s1_readdata),   //                    .readdata
		.out_port   (seg1_export)                           // external_connection.export
	);

	pico_qsys_seg1 seg2 (
		.clk        (clk_clk),                              //                 clk.clk
		.reset_n    (~rst_controller_reset_out_reset),      //               reset.reset_n
		.address    (mm_interconnect_0_seg2_s1_address),    //                  s1.address
		.write_n    (~mm_interconnect_0_seg2_s1_write),     //                    .write_n
		.writedata  (mm_interconnect_0_seg2_s1_writedata),  //                    .writedata
		.chipselect (mm_interconnect_0_seg2_s1_chipselect), //                    .chipselect
		.readdata   (mm_interconnect_0_seg2_s1_readdata),   //                    .readdata
		.out_port   (seg2_export)                           // external_connection.export
	);

	pico_qsys_sw sw (
		.clk      (clk_clk),                          //                 clk.clk
		.reset_n  (~rst_controller_reset_out_reset),  //               reset.reset_n
		.address  (mm_interconnect_0_sw_s1_address),  //                  s1.address
		.readdata (mm_interconnect_0_sw_s1_readdata), //                    .readdata
		.in_port  (sw_export)                         // external_connection.export
	);

	pico_qsys_uart_0 uart_0 (
		.clk           (clk_clk),                                   //                 clk.clk
		.reset_n       (~rst_controller_reset_out_reset),           //               reset.reset_n
		.address       (mm_interconnect_0_uart_0_s1_address),       //                  s1.address
		.begintransfer (mm_interconnect_0_uart_0_s1_begintransfer), //                    .begintransfer
		.chipselect    (mm_interconnect_0_uart_0_s1_chipselect),    //                    .chipselect
		.read_n        (~mm_interconnect_0_uart_0_s1_read),         //                    .read_n
		.write_n       (~mm_interconnect_0_uart_0_s1_write),        //                    .write_n
		.writedata     (mm_interconnect_0_uart_0_s1_writedata),     //                    .writedata
		.readdata      (mm_interconnect_0_uart_0_s1_readdata),      //                    .readdata
		.rxd           (uart_rxd),                                  // external_connection.export
		.txd           (uart_txd),                                  //                    .export
		.irq           (irq_mapper_receiver0_irq)                   //                 irq.irq
	);

	pico_qsys_mm_interconnect_0 mm_interconnect_0 (
		.pico_axilite_0_altera_axi4lite_master_awaddr     (pico_axilite_0_altera_axi4lite_master_awaddr),  //      pico_axilite_0_altera_axi4lite_master.awaddr
		.pico_axilite_0_altera_axi4lite_master_awprot     (pico_axilite_0_altera_axi4lite_master_awprot),  //                                           .awprot
		.pico_axilite_0_altera_axi4lite_master_awvalid    (pico_axilite_0_altera_axi4lite_master_awvalid), //                                           .awvalid
		.pico_axilite_0_altera_axi4lite_master_awready    (pico_axilite_0_altera_axi4lite_master_awready), //                                           .awready
		.pico_axilite_0_altera_axi4lite_master_wdata      (pico_axilite_0_altera_axi4lite_master_wdata),   //                                           .wdata
		.pico_axilite_0_altera_axi4lite_master_wstrb      (pico_axilite_0_altera_axi4lite_master_wstrb),   //                                           .wstrb
		.pico_axilite_0_altera_axi4lite_master_wvalid     (pico_axilite_0_altera_axi4lite_master_wvalid),  //                                           .wvalid
		.pico_axilite_0_altera_axi4lite_master_wready     (pico_axilite_0_altera_axi4lite_master_wready),  //                                           .wready
		.pico_axilite_0_altera_axi4lite_master_bresp      (pico_axilite_0_altera_axi4lite_master_bresp),   //                                           .bresp
		.pico_axilite_0_altera_axi4lite_master_bvalid     (pico_axilite_0_altera_axi4lite_master_bvalid),  //                                           .bvalid
		.pico_axilite_0_altera_axi4lite_master_bready     (pico_axilite_0_altera_axi4lite_master_bready),  //                                           .bready
		.pico_axilite_0_altera_axi4lite_master_araddr     (pico_axilite_0_altera_axi4lite_master_araddr),  //                                           .araddr
		.pico_axilite_0_altera_axi4lite_master_arprot     (pico_axilite_0_altera_axi4lite_master_arprot),  //                                           .arprot
		.pico_axilite_0_altera_axi4lite_master_arvalid    (pico_axilite_0_altera_axi4lite_master_arvalid), //                                           .arvalid
		.pico_axilite_0_altera_axi4lite_master_arready    (pico_axilite_0_altera_axi4lite_master_arready), //                                           .arready
		.pico_axilite_0_altera_axi4lite_master_rdata      (pico_axilite_0_altera_axi4lite_master_rdata),   //                                           .rdata
		.pico_axilite_0_altera_axi4lite_master_rresp      (pico_axilite_0_altera_axi4lite_master_rresp),   //                                           .rresp
		.pico_axilite_0_altera_axi4lite_master_rvalid     (pico_axilite_0_altera_axi4lite_master_rvalid),  //                                           .rvalid
		.pico_axilite_0_altera_axi4lite_master_rready     (pico_axilite_0_altera_axi4lite_master_rready),  //                                           .rready
		.clk_0_clk_clk                                    (clk_clk),                                       //                                  clk_0_clk.clk
		.pico_axilite_0_reset_reset_bridge_in_reset_reset (rst_controller_reset_out_reset),                // pico_axilite_0_reset_reset_bridge_in_reset.reset
		.led_s1_address                                   (mm_interconnect_0_led_s1_address),              //                                     led_s1.address
		.led_s1_write                                     (mm_interconnect_0_led_s1_write),                //                                           .write
		.led_s1_readdata                                  (mm_interconnect_0_led_s1_readdata),             //                                           .readdata
		.led_s1_writedata                                 (mm_interconnect_0_led_s1_writedata),            //                                           .writedata
		.led_s1_chipselect                                (mm_interconnect_0_led_s1_chipselect),           //                                           .chipselect
		.RAM_s1_address                                   (mm_interconnect_0_ram_s1_address),              //                                     RAM_s1.address
		.RAM_s1_write                                     (mm_interconnect_0_ram_s1_write),                //                                           .write
		.RAM_s1_readdata                                  (mm_interconnect_0_ram_s1_readdata),             //                                           .readdata
		.RAM_s1_writedata                                 (mm_interconnect_0_ram_s1_writedata),            //                                           .writedata
		.RAM_s1_byteenable                                (mm_interconnect_0_ram_s1_byteenable),           //                                           .byteenable
		.RAM_s1_chipselect                                (mm_interconnect_0_ram_s1_chipselect),           //                                           .chipselect
		.RAM_s1_clken                                     (mm_interconnect_0_ram_s1_clken),                //                                           .clken
		.ROM_s1_address                                   (mm_interconnect_0_rom_s1_address),              //                                     ROM_s1.address
		.ROM_s1_write                                     (mm_interconnect_0_rom_s1_write),                //                                           .write
		.ROM_s1_readdata                                  (mm_interconnect_0_rom_s1_readdata),             //                                           .readdata
		.ROM_s1_writedata                                 (mm_interconnect_0_rom_s1_writedata),            //                                           .writedata
		.ROM_s1_byteenable                                (mm_interconnect_0_rom_s1_byteenable),           //                                           .byteenable
		.ROM_s1_chipselect                                (mm_interconnect_0_rom_s1_chipselect),           //                                           .chipselect
		.ROM_s1_clken                                     (mm_interconnect_0_rom_s1_clken),                //                                           .clken
		.ROM_s1_debugaccess                               (mm_interconnect_0_rom_s1_debugaccess),          //                                           .debugaccess
		.seg1_s1_address                                  (mm_interconnect_0_seg1_s1_address),             //                                    seg1_s1.address
		.seg1_s1_write                                    (mm_interconnect_0_seg1_s1_write),               //                                           .write
		.seg1_s1_readdata                                 (mm_interconnect_0_seg1_s1_readdata),            //                                           .readdata
		.seg1_s1_writedata                                (mm_interconnect_0_seg1_s1_writedata),           //                                           .writedata
		.seg1_s1_chipselect                               (mm_interconnect_0_seg1_s1_chipselect),          //                                           .chipselect
		.seg2_s1_address                                  (mm_interconnect_0_seg2_s1_address),             //                                    seg2_s1.address
		.seg2_s1_write                                    (mm_interconnect_0_seg2_s1_write),               //                                           .write
		.seg2_s1_readdata                                 (mm_interconnect_0_seg2_s1_readdata),            //                                           .readdata
		.seg2_s1_writedata                                (mm_interconnect_0_seg2_s1_writedata),           //                                           .writedata
		.seg2_s1_chipselect                               (mm_interconnect_0_seg2_s1_chipselect),          //                                           .chipselect
		.sw_s1_address                                    (mm_interconnect_0_sw_s1_address),               //                                      sw_s1.address
		.sw_s1_readdata                                   (mm_interconnect_0_sw_s1_readdata),              //                                           .readdata
		.uart_0_s1_address                                (mm_interconnect_0_uart_0_s1_address),           //                                  uart_0_s1.address
		.uart_0_s1_write                                  (mm_interconnect_0_uart_0_s1_write),             //                                           .write
		.uart_0_s1_read                                   (mm_interconnect_0_uart_0_s1_read),              //                                           .read
		.uart_0_s1_readdata                               (mm_interconnect_0_uart_0_s1_readdata),          //                                           .readdata
		.uart_0_s1_writedata                              (mm_interconnect_0_uart_0_s1_writedata),         //                                           .writedata
		.uart_0_s1_begintransfer                          (mm_interconnect_0_uart_0_s1_begintransfer),     //                                           .begintransfer
		.uart_0_s1_chipselect                             (mm_interconnect_0_uart_0_s1_chipselect)         //                                           .chipselect
	);

	pico_qsys_irq_mapper irq_mapper (
		.clk           (clk_clk),                                 //       clk.clk
		.reset         (rst_controller_reset_out_reset),          // clk_reset.reset
		.receiver0_irq (irq_mapper_receiver0_irq),                // receiver0.irq
		.sender_irq    (pico_axilite_0_interrupt_receiver_0_irq)  //    sender.irq
	);

	altera_reset_controller #(
		.NUM_RESET_INPUTS          (1),
		.OUTPUT_RESET_SYNC_EDGES   ("deassert"),
		.SYNC_DEPTH                (2),
		.RESET_REQUEST_PRESENT     (1),
		.RESET_REQ_WAIT_TIME       (1),
		.MIN_RST_ASSERTION_TIME    (3),
		.RESET_REQ_EARLY_DSRT_TIME (1),
		.USE_RESET_REQUEST_IN0     (0),
		.USE_RESET_REQUEST_IN1     (0),
		.USE_RESET_REQUEST_IN2     (0),
		.USE_RESET_REQUEST_IN3     (0),
		.USE_RESET_REQUEST_IN4     (0),
		.USE_RESET_REQUEST_IN5     (0),
		.USE_RESET_REQUEST_IN6     (0),
		.USE_RESET_REQUEST_IN7     (0),
		.USE_RESET_REQUEST_IN8     (0),
		.USE_RESET_REQUEST_IN9     (0),
		.USE_RESET_REQUEST_IN10    (0),
		.USE_RESET_REQUEST_IN11    (0),
		.USE_RESET_REQUEST_IN12    (0),
		.USE_RESET_REQUEST_IN13    (0),
		.USE_RESET_REQUEST_IN14    (0),
		.USE_RESET_REQUEST_IN15    (0),
		.ADAPT_RESET_REQUEST       (0)
	) rst_controller (
		.reset_in0      (~reset_reset_n),                     // reset_in0.reset
		.clk            (clk_clk),                            //       clk.clk
		.reset_out      (rst_controller_reset_out_reset),     // reset_out.reset
		.reset_req      (rst_controller_reset_out_reset_req), //          .reset_req
		.reset_req_in0  (1'b0),                               // (terminated)
		.reset_in1      (1'b0),                               // (terminated)
		.reset_req_in1  (1'b0),                               // (terminated)
		.reset_in2      (1'b0),                               // (terminated)
		.reset_req_in2  (1'b0),                               // (terminated)
		.reset_in3      (1'b0),                               // (terminated)
		.reset_req_in3  (1'b0),                               // (terminated)
		.reset_in4      (1'b0),                               // (terminated)
		.reset_req_in4  (1'b0),                               // (terminated)
		.reset_in5      (1'b0),                               // (terminated)
		.reset_req_in5  (1'b0),                               // (terminated)
		.reset_in6      (1'b0),                               // (terminated)
		.reset_req_in6  (1'b0),                               // (terminated)
		.reset_in7      (1'b0),                               // (terminated)
		.reset_req_in7  (1'b0),                               // (terminated)
		.reset_in8      (1'b0),                               // (terminated)
		.reset_req_in8  (1'b0),                               // (terminated)
		.reset_in9      (1'b0),                               // (terminated)
		.reset_req_in9  (1'b0),                               // (terminated)
		.reset_in10     (1'b0),                               // (terminated)
		.reset_req_in10 (1'b0),                               // (terminated)
		.reset_in11     (1'b0),                               // (terminated)
		.reset_req_in11 (1'b0),                               // (terminated)
		.reset_in12     (1'b0),                               // (terminated)
		.reset_req_in12 (1'b0),                               // (terminated)
		.reset_in13     (1'b0),                               // (terminated)
		.reset_req_in13 (1'b0),                               // (terminated)
		.reset_in14     (1'b0),                               // (terminated)
		.reset_req_in14 (1'b0),                               // (terminated)
		.reset_in15     (1'b0),                               // (terminated)
		.reset_req_in15 (1'b0)                                // (terminated)
	);

endmodule
