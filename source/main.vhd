-----------------------------
--! @author Imants Pulkstenis 
--! @date 17.03.2020 
--! @file main.vhd
--! @version B
--! @copyright Copyright (c) 2021 Imants Pulkstenis
--! 
--! @brief *Project name:* Delay line 
--! *Module name:* Delay line TOP entity
--! 
--! @details *Detailed description*:
--! Tis is very long CARRY4 delay line for delay testing on oscilloscope.
--! **Revision:**
--! A - initial design  
--! B - this version are for delay line testing
--! C - 

LIBRARY IEEE; --always use this library
USE IEEE.std_logic_unsigned.ALL; --extends the std_logic_arith library
USE IEEE.std_logic_arith.ALL; --basic arithmetic operations for representing integers in standard ways
USE IEEE.numeric_std.ALL; --use this library if arithmetic required
USE IEEE.std_logic_1164.ALL; --always use this library

ENTITY main IS
    GENERIC (
        g_DL_ELEMENT_COUNT : INTEGER := 150 * 4 --! delay element count in delay line. It must be n*4.
    );
    PORT (
        -- -- Hardware on Basys 3 development board
        i_clk : IN STD_LOGIC; --! 100MHz clock
        o_clock : OUT STD_LOGIC; --! In FPGA (PLL) generated test signal that is connected to output pin without delay
        o_delay_clock : OUT STD_LOGIC --! In FPGA generated test signal that is driven through delay line and then to output pin for comparison with not delayed clock
    );
END main; --! Delay line TOP entity

ARCHITECTURE rtl OF main IS

    SIGNAL w_clk10 : STD_LOGIC; --! 10MHz clock for testing delay loop
    SIGNAL w_clk100 : STD_LOGIC; --! 100MHz main clock 
    SIGNAL w_delay_0 : STD_LOGIC; --! output of delay line No.0 
    SIGNAL w_delay_1 : STD_LOGIC; --! output of delay line No.1 
    ATTRIBUTE keep : STRING;
    ATTRIBUTE keep OF w_clk10 : SIGNAL IS "true";
    ATTRIBUTE keep OF w_clk100 : SIGNAL IS "true";

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
            -- Clock in ports
            i_clk1 => i_clk --! Clock in ports 
        );

    --! delay line No.0
    --! 
    delay_line_inst_0 : ENTITY work.delay_line
        GENERIC MAP(
            g_DL_ELEMENT_COUNT => g_DL_ELEMENT_COUNT,
            g_LOCATION => "SLICE_X0Y0"
        )
        PORT MAP(
            TriggerIn => w_clk10, --! Input of delay line
            LoopOut => w_delay_0
        );

    --! delay line No.1
    --! 
    delay_line_inst_1 : ENTITY work.delay_line
        GENERIC MAP(
            g_DL_ELEMENT_COUNT => g_DL_ELEMENT_COUNT,
            g_LOCATION => "SLICE_X1Y0"
        )
        PORT MAP(
            TriggerIn => w_delay_0, --! Input of delay line
            LoopOut => w_delay_1 --! Output of delay line 
        );

    ---------------------------------------------------------    
    --                   reg-state logic                   --
    ---------------------------------------------------------

    ---------------------------------------------------------
    --                  next-state logic                   --
    ---------------------------------------------------------

    ---------------------------------------------------------
    --                       outputs                       --
    --------------------------------------------------------- 

    o_clock <= w_clk10;
    o_delay_clock <= w_delay_1;
END rtl;