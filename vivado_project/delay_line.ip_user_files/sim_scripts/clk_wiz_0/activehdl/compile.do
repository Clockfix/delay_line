vlib work
vlib activehdl

vlib activehdl/work
vlib activehdl/xil_defaultlib

vmap work activehdl/work
vmap xil_defaultlib activehdl/xil_defaultlib

vlog -work work  -v2k5 "+incdir+../../../ipstatic" \
"../../../../delay_line.srcs/sources_1/ip/clk_wiz_0/clk_wiz_0_clk_wiz.v" \
"../../../../delay_line.srcs/sources_1/ip/clk_wiz_0/clk_wiz_0.v" \


vlog -work work \
"glbl.v"

