	component pico_qsys is
		port (
			clk_clk       : in  std_logic                    := 'X'; -- clk
			reset_reset_n : in  std_logic                    := 'X'; -- reset_n
			uart_rxd      : in  std_logic                    := 'X'; -- rxd
			uart_txd      : out std_logic;                           -- txd
			led_export    : out std_logic_vector(7 downto 0)         -- export
		);
	end component pico_qsys;

	u0 : component pico_qsys
		port map (
			clk_clk       => CONNECTED_TO_clk_clk,       --   clk.clk
			reset_reset_n => CONNECTED_TO_reset_reset_n, -- reset.reset_n
			uart_rxd      => CONNECTED_TO_uart_rxd,      --  uart.rxd
			uart_txd      => CONNECTED_TO_uart_txd,      --      .txd
			led_export    => CONNECTED_TO_led_export     --   led.export
		);

