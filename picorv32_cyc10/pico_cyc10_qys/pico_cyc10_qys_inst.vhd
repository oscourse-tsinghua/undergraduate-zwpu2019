	component pico_cyc10_qys is
		port (
			clk_clk       : in  std_logic                    := 'X'; -- clk
			led_export    : out std_logic_vector(7 downto 0);        -- export
			reset_reset_n : in  std_logic                    := 'X'; -- reset_n
			seg_export    : out std_logic_vector(7 downto 0);        -- export
			trap_export   : out std_logic;                           -- export
			uart_rxd      : in  std_logic                    := 'X'; -- rxd
			uart_txd      : out std_logic                            -- txd
		);
	end component pico_cyc10_qys;

	u0 : component pico_cyc10_qys
		port map (
			clk_clk       => CONNECTED_TO_clk_clk,       --   clk.clk
			led_export    => CONNECTED_TO_led_export,    --   led.export
			reset_reset_n => CONNECTED_TO_reset_reset_n, -- reset.reset_n
			seg_export    => CONNECTED_TO_seg_export,    --   seg.export
			trap_export   => CONNECTED_TO_trap_export,   --  trap.export
			uart_rxd      => CONNECTED_TO_uart_rxd,      --  uart.rxd
			uart_txd      => CONNECTED_TO_uart_txd       --      .txd
		);

