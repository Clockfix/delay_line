vlib work
vlib riviera

vlib riviera/work
vlib riviera/xil_defaultlib

vmap work riviera/work
vmap xil_defaultlib riviera/xil_defaultlib

vlog -work work  -v2k5 "+incdir+../../../ipstatic" \
"../../../../delay_line.srcs/sources_1/ip/clk_wiz_0/clk_wiz_0_clk_wiz.v" \
"../../../../delay_line.srcs/sources_1/ip/clk_wiz_0/clk_wiz_0.v" \


vlog -work work \
"glbl.v"

