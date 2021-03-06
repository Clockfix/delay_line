-- (c) Copyright 1995-2021 Xilinx, Inc. All rights reserved.
-- 
-- This file contains confidential and proprietary information
-- of Xilinx, Inc. and is protected under U.S. and
-- international copyright and other intellectual property
-- laws.
-- 
-- DISCLAIMER
-- This disclaimer is not a license and does not grant any
-- rights to the materials distributed herewith. Except as
-- otherwise provided in a valid license issued to you by
-- Xilinx, and to the maximum extent permitted by applicable
-- law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
-- WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
-- AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
-- BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
-- INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
-- (2) Xilinx shall not be liable (whether in contract or tort,
-- including negligence, or under any other theory of
-- liability) for any loss or damage of any kind or nature
-- related to, arising under or in connection with these
-- materials, including for any direct, or any indirect,
-- special, incidental, or consequential loss or damage
-- (including loss of data, profits, goodwill, or any type of
-- loss or damage suffered as a result of any action brought
-- by a third party) even if such damage or loss was
-- reasonably foreseeable or Xilinx had been advised of the
-- possibility of the same.
-- 
-- CRITICAL APPLICATIONS
-- Xilinx products are not designed or intended to be fail-
-- safe, or for use in any application requiring fail-safe
-- performance, such as life-support or safety devices or
-- systems, Class III medical devices, nuclear facilities,
-- applications related to the deployment of airbags, or any
-- other applications that could lead to death, personal
-- injury, or severe property or environmental damage
-- (individually and collectively, "Critical
-- Applications"). Customer assumes the sole risk and
-- liability of any use of Xilinx products in Critical
-- Applications, subject only to applicable laws and
-- regulations governing limitations on product liability.
-- 
-- THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
-- PART OF THIS FILE AT ALL TIMES.
-- 
-- DO NOT MODIFY THIS FILE.

-- IP VLNV: xilinx.com:ip:i2s_receiver:1.0
-- IP Revision: 4

-- The following code must appear in the VHDL architecture header.

------------- Begin Cut here for COMPONENT Declaration ------ COMP_TAG
COMPONENT i2s_receiver_0
  PORT (
    s_axi_ctrl_aclk : IN STD_LOGIC;
    s_axi_ctrl_aresetn : IN STD_LOGIC;
    aud_mclk : IN STD_LOGIC;
    aud_mrst : IN STD_LOGIC;
    m_axis_aud_aclk : IN STD_LOGIC;
    m_axis_aud_aresetn : IN STD_LOGIC;
    s_axi_ctrl_awvalid : IN STD_LOGIC;
    s_axi_ctrl_awready : OUT STD_LOGIC;
    s_axi_ctrl_awaddr : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    s_axi_ctrl_wvalid : IN STD_LOGIC;
    s_axi_ctrl_wready : OUT STD_LOGIC;
    s_axi_ctrl_wdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    s_axi_ctrl_bvalid : OUT STD_LOGIC;
    s_axi_ctrl_bready : IN STD_LOGIC;
    s_axi_ctrl_bresp : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    s_axi_ctrl_arvalid : IN STD_LOGIC;
    s_axi_ctrl_arready : OUT STD_LOGIC;
    s_axi_ctrl_araddr : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    s_axi_ctrl_rvalid : OUT STD_LOGIC;
    s_axi_ctrl_rready : IN STD_LOGIC;
    s_axi_ctrl_rdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    s_axi_ctrl_rresp : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    irq : OUT STD_LOGIC;
    lrclk_out : OUT STD_LOGIC;
    sclk_out : OUT STD_LOGIC;
    sdata_0_in : IN STD_LOGIC;
    m_axis_aud_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    m_axis_aud_tid : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    m_axis_aud_tvalid : OUT STD_LOGIC;
    m_axis_aud_tready : IN STD_LOGIC
  );
END COMPONENT;
-- COMP_TAG_END ------ End COMPONENT Declaration ------------

-- The following code must appear in the VHDL architecture
-- body. Substitute your own instance name and net names.

------------- Begin Cut here for INSTANTIATION Template ----- INST_TAG
your_instance_name : i2s_receiver_0
  PORT MAP (
    s_axi_ctrl_aclk => s_axi_ctrl_aclk,
    s_axi_ctrl_aresetn => s_axi_ctrl_aresetn,
    aud_mclk => aud_mclk,
    aud_mrst => aud_mrst,
    m_axis_aud_aclk => m_axis_aud_aclk,
    m_axis_aud_aresetn => m_axis_aud_aresetn,
    s_axi_ctrl_awvalid => s_axi_ctrl_awvalid,
    s_axi_ctrl_awready => s_axi_ctrl_awready,
    s_axi_ctrl_awaddr => s_axi_ctrl_awaddr,
    s_axi_ctrl_wvalid => s_axi_ctrl_wvalid,
    s_axi_ctrl_wready => s_axi_ctrl_wready,
    s_axi_ctrl_wdata => s_axi_ctrl_wdata,
    s_axi_ctrl_bvalid => s_axi_ctrl_bvalid,
    s_axi_ctrl_bready => s_axi_ctrl_bready,
    s_axi_ctrl_bresp => s_axi_ctrl_bresp,
    s_axi_ctrl_arvalid => s_axi_ctrl_arvalid,
    s_axi_ctrl_arready => s_axi_ctrl_arready,
    s_axi_ctrl_araddr => s_axi_ctrl_araddr,
    s_axi_ctrl_rvalid => s_axi_ctrl_rvalid,
    s_axi_ctrl_rready => s_axi_ctrl_rready,
    s_axi_ctrl_rdata => s_axi_ctrl_rdata,
    s_axi_ctrl_rresp => s_axi_ctrl_rresp,
    irq => irq,
    lrclk_out => lrclk_out,
    sclk_out => sclk_out,
    sdata_0_in => sdata_0_in,
    m_axis_aud_tdata => m_axis_aud_tdata,
    m_axis_aud_tid => m_axis_aud_tid,
    m_axis_aud_tvalid => m_axis_aud_tvalid,
    m_axis_aud_tready => m_axis_aud_tready
  );
-- INST_TAG_END ------ End INSTANTIATION Template ---------

-- You must compile the wrapper file i2s_receiver_0.vhd when simulating
-- the core, i2s_receiver_0. When compiling the wrapper file, be sure to
-- reference the VHDL simulation library.

