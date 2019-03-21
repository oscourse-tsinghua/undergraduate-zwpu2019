onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /pico_tb/clk
add wave -noupdate /pico_tb/rst
add wave -noupdate /pico_tb/rx
add wave -noupdate /pico_tb/tx
add wave -noupdate /pico_tb/led
add wave -noupdate /pico_tb/seg1
add wave -noupdate /pico_tb/seg2
add wave -noupdate -radix hexadecimal /pico_tb/uo/u0/pico_axilite_0/axm_araddr
add wave -noupdate -radix hexadecimal /pico_tb/uo/u0/pico_axilite_0/axm_rdata
add wave -noupdate -radix hexadecimal /pico_tb/uo/u0/pico_axilite_0/axm_awaddr
add wave -noupdate -radix hexadecimal /pico_tb/uo/u0/pico_axilite_0/axm_wdata
add wave -noupdate /pico_tb/uo/u0/pico_axilite_0/axm_wstrb
add wave -noupdate /pico_tb/uo/u0/uart_0/readdata
add wave -noupdate /pico_tb/uo/u0/uart_0/writedata
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {369 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 354
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {1036433050 ps} {1036433885 ps}
