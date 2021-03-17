-----------------------------
--! @author Imants Pulkstenis 
--! @date 17.03.2020 
--! @file io_buffer.vhd
--! @version A
--! @copyright Copyright (c) 2021 Imants Pulkstenis
--! 
--! @brief *Project name:* Delay line 
--! *Module name:* Input and Output buffer entity
--! 
--! @details *Detailed description*:
--! This module inference *OBUF* and *IBUF* in one entity
--! **Revision:**
--! A - initial design  
--! B -  

-----------------------------
--! ***schematic*** representation:
--! { assign:[
--!   [" " ,"io","o",["~",
--!     ["~","i"] 
--!   ]]
--! ]}
-----------------------------

LIBRARY IEEE; -- always use this library
USE IEEE.std_logic_1164.ALL; -- always use this library
Library UNISIM; -- Xilinx HDL Libraries
use UNISIM.vcomponents.all; -- Xilinx HDL Libraries

ENTITY io_buffer IS
    PORT (
        i : IN STD_LOGIC; --! Buffer input
      --  t : IN STD_LOGIC; --! 3-state enable input, high=input, low=output
        o : OUT STD_LOGIC; --!  Buffer output
        io : OUT STD_LOGIC --! Buffer inout port (connect directly to top-level port)
    );
END io_buffer; 

ARCHITECTURE arch OF io_buffer IS

BEGIN
    --! IOBUF: Single-ended Bi-directional Buffer
    --! 7 Series
    --! Xilinx HDL Libraries Guide, version 14.1
    IOBUF_inst : IOBUF
    GENERIC MAP(
        DRIVE => 12,
        IOSTANDARD => "DEFAULT",
        SLEW => "SLOW")
    PORT MAP(
        O => O, -- Buffer output
        IO => IO, -- Buffer inout port (connect directly to top-level port)
        I => I, -- Buffer input
        T => '0' -- 3-state enable input, high=input, low=output
    );
    --! End of IOBUF_inst instantiation
END arch;