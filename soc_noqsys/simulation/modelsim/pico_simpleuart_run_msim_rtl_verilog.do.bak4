transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+C:/Users/91947/Desktop/final/soc_noqsys {C:/Users/91947/Desktop/final/soc_noqsys/picosoc.v}
vlog -vlog01compat -work work +incdir+C:/Users/91947/Desktop/final/soc_noqsys {C:/Users/91947/Desktop/final/soc_noqsys/picorv32.v}
vlog -vlog01compat -work work +incdir+C:/Users/91947/Desktop/final/soc_noqsys {C:/Users/91947/Desktop/final/soc_noqsys/simpleuart.v}
vlog -vlog01compat -work work +incdir+C:/Users/91947/Desktop/final/soc_noqsys/ip {C:/Users/91947/Desktop/final/soc_noqsys/ip/rom.v}
vlog -vlog01compat -work work +incdir+C:/Users/91947/Desktop/final/soc_noqsys/ip {C:/Users/91947/Desktop/final/soc_noqsys/ip/ram.v}

vlog -vlog01compat -work work +incdir+C:/Users/91947/Desktop/final/soc_noqsys {C:/Users/91947/Desktop/final/soc_noqsys/picosoc_tb.v}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L fiftyfivenm_ver -L rtl_work -L work -voptargs="+acc"  picosoc_tb

add wave *
view structure
view signals
run -all
