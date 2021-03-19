// Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2020.1 (win64) Build 2902540 Wed May 27 19:54:49 MDT 2020
// Date        : Fri Mar 19 09:33:50 2021
// Host        : DESKTOP-7DQ2053 running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               c:/work/2021/delay_line/vivado_project/delay_line.srcs/sources_1/ip/clk_wiz_0/clk_wiz_0_stub.v
// Design      : clk_wiz_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a35tcpg236-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module clk_wiz_0(o_clk100, o_clk10, reset, locked, i_clk1)
/* synthesis syn_black_box black_box_pad_pin="o_clk100,o_clk10,reset,locked,i_clk1" */;
  output o_clk100;
  output o_clk10;
  input reset;
  output locked;
  input i_clk1;
endmodule
