	component pico_qsys is
		port (
			clk_clk       : in  std_logic                    := 'X';             -- clk
			reset_reset_n : in  std_logic                    := 'X';             -- reset_n
			uart_rxd      : in  std_logic                    := 'X';             -- rxd
			uart_txd      : out std_logic;                                       -- txd
			led_export    : out std_logic_vector(7 downto 0);                    -- export
			sw_export     : in  std_logic_vector(7 downto 0) := (others => 'X'); -- export
			seg1_export   : out std_logic_vector(7 downto 0);                    -- export
			seg2_export   : out std_logic_vector(7 downto 0);                    -- export
			trap_export   : out std_logic                                        -- export
		);
	end component pico_qsys;

	u0 : component pico_qsys
		port map (
			clk_clk       => CONNECTED_TO_clk_clk,       --   clk.clk
			reset_reset_n => CONNECTED_TO_reset_reset_n, -- reset.reset_n
			uart_rxd      => CONNECTED_TO_uart_rxd,      --  uart.rxd
			uart_txd      => CONNECTED_TO_uart_txd,      --      .txd
			led_export    => CONNECTED_TO_led_export,    --   led.export
			sw_export     => CONNECTED_TO_sw_export,     --    sw.export
			seg1_export   => CONNECTED_TO_seg1_export,   --  seg1.export
			seg2_export   => CONNECTED_TO_seg2_export,   --  seg2.export
			trap_export   => CONNECTED_TO_trap_export    --  trap.export
		);

