vlib work
vlib riviera

vlib riviera/xpm
vlib riviera/work
vlib riviera/xil_defaultlib

vmap xpm riviera/xpm
vmap work riviera/work
vmap xil_defaultlib riviera/xil_defaultlib

vlog -work xpm  -sv2k12 "+incdir+../../../ipstatic" \
"/home/imants/programs/Xilinx/Vivado/Vivado/2020.1/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \

vcom -work xpm -93 \
"/home/imants/programs/Xilinx/Vivado/Vivado/2020.1/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -work work  -v2k5 "+incdir+../../../ipstatic" \
"../../../../delay_line.srcs/sources_1/ip/clk_wiz_0_1/clk_wiz_0_clk_wiz.v" \
"../../../../delay_line.srcs/sources_1/ip/clk_wiz_0_1/clk_wiz_0.v" \

vlog -work work \
"glbl.v"
