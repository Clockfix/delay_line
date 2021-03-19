-----------------------------
--! @author Imants Pulkstenis 
--! @date 19.03.2021 
--! @file clock_gen.vhd
--! @version A
--! @copyright Copyright (c) 2021 Imants Pulkstenis
--! 
--! @brief *Project name:* Delay line 
--! *Module name:* Clock generator entity containing PLL and other clock controls
--! 
--! @details *Detailed description*:
--! ()
--! **Revision:**
--! A - initial design  
--! B - 
--! C - 

LIBRARY IEEE; --always use this library
USE IEEE.numeric_std.ALL; --use this library if arithmetic required
USE IEEE.std_logic_1164.ALL; --always use this library
LIBRARY UNISIM; -- Xilinx HDL Libraries
USE UNISIM.vcomponents.ALL; -- Xilinx HDL Libraries

ENTITY clock_gen IS
    PORT (
        -- -- Hardware on Basys 3 development board
        i_clk : IN STD_LOGIC; --! Main clock input. For Basys3 board it is 100MHz
        o_clock100 : OUT STD_LOGIC; --! In FPGA (PLL) generated clock
        o_clock10 : OUT STD_LOGIC --! In FPGA (PLL) generated clock
    );
END clock_gen; --! Delay line TOP entity

ARCHITECTURE rtl OF clock_gen IS

    SIGNAL w_clk10 : STD_LOGIC; --! 10MHz clock for testing delay loop
    SIGNAL w_clk100 : STD_LOGIC; --! 100MHz main clock  
    SIGNAL w_locked : STD_LOGIC; --! locked output from PLL

BEGIN
    ---------------------------------------------------------    
    --             instantiate sub entities                --
    ---------------------------------------------------------

    --! PLL clock generator for test purposes
    clk_wiz_instance : ENTITY work.clk_wiz_0
        PORT MAP(
            -- Clock out ports  
            o_clk10 => w_clk10, --! Clock out ports 
            o_clk100 => w_clk100, --! Clock out ports 
            -- Status and control signals                
            reset => '0', --! active high RESET
            locked => w_locked,
            -- Clock in ports
            i_clk1 => i_clk --! Clock in ports 
        );

    --! BUFGCE: Global Clock Buffer with Clock Enable
    --! 7 Series
    --! Xilinx HDL Libraries Guide, version 14.1
    BUFGCE_inst_clk100 : BUFGCE
    GENERIC MAP(
        SIM_DEVICE => "7SERIES" --! To avoid WARNING: [Netlist 29-345] The value of SIM_DEVICE on instance
    )
    PORT MAP(
        O => o_clock100, --! 1-bit output: Clock output
        CE => w_locked, --! 1-bit input: Clock enable input for I0
        I => w_clk100 --! 1-bit input: Primary clock
    );
    -- End of BUFGCE_inst instantiation

    --! BUFGCE: Global Clock Buffer with Clock Enable
    --! 7 Series
    --! Xilinx HDL Libraries Guide, version 14.1
    BUFGCE_inst_clk10 : BUFGCE
    GENERIC MAP(
        SIM_DEVICE => "7SERIES" --! To avoid WARNING: [Netlist 29-345] The value of SIM_DEVICE on instance
    )
    PORT MAP(
        O => o_clock10, --! 1-bit output: Clock output
        CE => w_locked, --! 1-bit input: Clock enable input for I0
        I => w_clk100 --! 1-bit input: Primary clock
    );
    -- End of BUFGCE_inst instantiation

END rtl;