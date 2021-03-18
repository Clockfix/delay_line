-----------------------------
--! @author Imants Pulkstenis
--! @date 18.03.2020
--! @file buffer_inverter.vhd
--! @version A
--! @copyright Copyright (c) 2021 Imants Pulkstenis
--! 
--! @brief Project name: Delay line
--! Module name: NOT gate implementation 
--! 
--! @details buffer/inverter are based on LUT1 primitive
--! Primitive: 1-Bit Look-Up Table with General Output
--! To change functionality of the entity g_INIT value must be changed.
--! When g_INIT="01" entity behaves as inverter, but if g_INIT="10" as buffer.
--! -------------------------------------------------------------
--! **Revision:**
--! A - initial design
--! B - 
--! C - 
--! -----------------------------

-----------------------------
--! ***schematic*** representation:
--! { assign:[
--!   ["o",
--!     ["~","i"] 
--!   ]
--! ]}
--! { assign:[
--!   ["o",
--!     ["=","i"] 
--!   ]
--! ]}
--! -----------------------------

LIBRARY IEEE; --always use this library
USE IEEE.std_logic_1164.ALL; --always use this library
LIBRARY UNISIM; -- Xilinx primitive
USE UNISIM.vcomponents.ALL; -- Xilinx primitive

ENTITY buffer_inverter IS
    GENERIC (
        g_INIT : STD_LOGIC_VECTOR(1 DOWNTO 0) := "10" --! Binary number assigned to the INIT attribute. Default value "10" that configures this LUT1 as buffer
    );
    PORT (
        i : IN STD_LOGIC; --! buffer/inverter Input 
        o : OUT STD_LOGIC --! buffer/inverter Output 
    );
END buffer_inverter;

ARCHITECTURE rtl OF buffer_inverter IS
BEGIN
    --! LUT1: 1-input Look-Up Table with general output
    --! 7 Series
    --! Xilinx HDL Libraries Guide, version 14.1
    LUT1_inst : LUT1
    GENERIC MAP(
        INIT => to_bitvector(g_INIT))
    PORT MAP(
        O => o, --! LUT general output
        I0 => i --! LUT input
    );
    -- End of LUT1_inst instantiation
END rtl;