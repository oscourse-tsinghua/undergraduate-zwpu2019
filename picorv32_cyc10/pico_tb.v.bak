`timescale 1 ns / 1 ps

module pico_tb;

reg clk, rst, rx;
wire tx;
wire [7:0] led;
wire [8:0] seg1, seg2;

//wire clk_50M;


task rx_task(input [7:0] data);
	begin
	rx = 0;
	#8720 rx = data[0];
	#8720 rx = data[1];
	#8720 rx = data[2];
	#8720 rx = data[3];
	#8720 rx = data[4];
	#8720 rx = data[5];
	#8720 rx = data[6];
	#8720 rx = data[7];
	#8720 rx = 1;
	end
endtask



initial begin
	clk = 0;
	forever #42 clk = ~clk;
end

initial begin
	rst = 0;
	#100 rst = 1;
end

initial begin
	rx = 1;
	#5000
	rx_task(8'b10101010);
end

pico_axilite_top uo(
	.clk(clk),
	.rst_n(rst),
	.rx(rx),
	.tx(tx),
	.led(led),
	.seg1(seg1),
	.seg2(seg2),
	.sw(4'b1111)
);


endmodule