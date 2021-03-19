vlib questa_lib/work
vlib questa_lib/msim

vlib questa_lib/msim/work
vlib questa_lib/msim/xil_defaultlib

vmap work questa_lib/msim/work
vmap xil_defaultlib questa_lib/msim/xil_defaultlib

vlog -work work  "+incdir+../../../ipstatic" \
"../../../../delay_line.srcs/sources_1/ip/clk_wiz_0/clk_wiz_0_clk_wiz.v" \
"../../../../delay_line.srcs/sources_1/ip/clk_wiz_0/clk_wiz_0.v" \


vlog -work work \
"glbl.v"

