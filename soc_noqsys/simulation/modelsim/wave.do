onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /picosoc_tb/clk
add wave -noupdate /picosoc_tb/rst
add wave -noupdate /picosoc_tb/rx
add wave -noupdate /picosoc_tb/tx
add wave -noupdate /picosoc_tb/led
add wave -noupdate /picosoc_tb/seg1
add wave -noupdate /picosoc_tb/seg2
add wave -noupdate /picosoc_tb/clk
add wave -noupdate /picosoc_tb/rst
add wave -noupdate /picosoc_tb/rx
add wave -noupdate /picosoc_tb/tx
add wave -noupdate /picosoc_tb/led
add wave -noupdate /picosoc_tb/seg1
add wave -noupdate /picosoc_tb/seg2
add wave -noupdate -radix hexadecimal /picosoc_tb/u0/mem_addr
add wave -noupdate -radix hexadecimal /picosoc_tb/u0/mem_instr
add wave -noupdate -radix hexadecimal /picosoc_tb/u0/mem_rdata
add wave -noupdate -radix hexadecimal /picosoc_tb/u0/mem_wdata
add wave -noupdate -radix hexadecimal /picosoc_tb/u0/simpleuart/reg_dat_do
add wave -noupdate -radix hexadecimal /picosoc_tb/u0/simpleuart/recv_buf_data
add wave -noupdate -radix hexadecimal /picosoc_tb/u0/simpleuart/recv_buf_valid
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {53406029 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 271
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
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {134361 ps}
