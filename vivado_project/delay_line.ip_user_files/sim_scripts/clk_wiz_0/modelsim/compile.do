vlib modelsim_lib/work
vlib modelsim_lib/msim

vlib modelsim_lib/msim/work
vlib modelsim_lib/msim/xil_defaultlib

vmap work modelsim_lib/msim/work
vmap xil_defaultlib modelsim_lib/msim/xil_defaultlib

vlog -work work  -incr "+incdir+../../../ipstatic" \
"../../../../delay_line.srcs/sources_1/ip/clk_wiz_0/clk_wiz_0_clk_wiz.v" \
"../../../../delay_line.srcs/sources_1/ip/clk_wiz_0/clk_wiz_0.v" \


vlog -work work \
"glbl.v"

