-----------------------------
--! @author Imants Pulkstenis 
--! @date 18.03.2021 
--! @file main.vhd
--! @version C
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
--! C - clock_wiz(PLL) are now placed in separate entity. Add loopback clock output and input for testing delay line and avoid Vivado warnings.
--! D -

LIBRARY IEEE; --always use this library
USE IEEE.std_logic_unsigned.ALL; --extends the std_logic_arith library
USE IEEE.std_logic_arith.ALL; --basic arithmetic operations for representing integers in standard ways
USE IEEE.numeric_std.ALL; --use this library if arithmetic required
USE IEEE.std_logic_1164.ALL; --always use this library

ENTITY main IS
    GENERIC (
        g_DELAY_LINE_COUNT : INTEGER := 4; --! count of delay lines 
        g_DL_ELEMENT_COUNT : INTEGER := 128 * 4 --! delay element count in delay line. It must be n*4.
    );
    PORT (
        -- -- Hardware on Basys 3 development board
        i_clk : IN STD_LOGIC; --! 100MHz clock
        o_clock : OUT STD_LOGIC; --! In FPGA (PLL) generated test signal that is connected to output pin without delay
        o_clock_loopback : OUT STD_LOGIC; --! o_clock_loopback and i_clock_loopback  are routed together on the board
        i_clock_loopback : IN STD_LOGIC; --! o_clock_loopback and i_clock_loopback  are routed together on the board
        o_delay_clock : OUT STD_LOGIC --! In FPGA generated test signal that is driven through delay line and then to output pin for comparison with not delayed clock
    );
END main; --! Delay line TOP entity

ARCHITECTURE rtl OF main IS

    SIGNAL w_clk10 : STD_LOGIC; --! 10MHz clock for testing delay loop
    SIGNAL w_clk100 : STD_LOGIC; --! 100MHz main clock 
    SIGNAL w_delay_interconnect : STD_LOGIC_VECTOR(g_DELAY_LINE_COUNT - 1 DOWNTO 0); --! interconnections of individual delay lines 
    SIGNAL w_term_code : STD_LOGIC_VECTOR(g_DL_ELEMENT_COUNT - 1 DOWNTO 0); --! interconnections of individual delay lines 
    ATTRIBUTE keep : STRING;
    ATTRIBUTE keep OF w_clk10 : SIGNAL IS "true";
    ATTRIBUTE keep OF w_clk100 : SIGNAL IS "true";

BEGIN
    ---------------------------------------------------------
    --                       outputs                       --
    --------------------------------------------------------- 

    o_clock <= w_clk10;
    o_clock_loopback <= w_clk10;
    o_delay_clock <= w_delay_interconnect(g_DELAY_LINE_COUNT - 1);
    
    
    ---------------------------------------------------------    
    --             instantiate sub entities                --
    ---------------------------------------------------------

    --! Clock generator entity
    clock_gen_inst : ENTITY work.clock_gen
        PORT MAP(
            i_clk => i_clk, --! Main clock input. For Basys3 board it is 100MHz
            o_clock100 => w_clk100, --! In FPGA (PLL) generated clock
            o_clock10 => w_clk10 --! In FPGA (PLL) generated clock
        );

    --  INSTANTIATION Template 
    --! FIFO memory 512x512
    fifo_instance : ENTITY work.fifo_generator_0
        PORT MAP(
            rst => '0',
            wr_clk => w_clk100,
            rd_clk => w_clk100,
            din => std_logic_vector(to_unsigned(0,512)),
            wr_en => '1',
            rd_en => '1'--,
            -- dout => dout,
            -- full => full,
            -- empty => empty
        );
    -- End INSTANTIATION Template 

    --! delay line No.0
    --! 
    delay_line_inst_0 : ENTITY work.delay_line
        GENERIC MAP(
            g_DL_ELEMENT_COUNT => g_DL_ELEMENT_COUNT/g_DELAY_LINE_COUNT,
            g_LOCATION => "SLICE_X36Y50"
        )
        PORT MAP(
            i_clk => w_clk100, --! Main clock for D-Flip-Flops
            i_trigger_in => i_clock_loopback, --! Input of delay line
            o_loop_out => w_delay_interconnect(0), --! Output of delay line
            o_dff_q => w_term_code(g_DL_ELEMENT_COUNT - 1 DOWNTO 0),
            i_D => "0000", --! DI for CARRY4 block
            i_S => "1111", --! S for CARRY4 block
            i_nReset => '1', --! Synchronous reset input for D-Flip-Flops
            i_clock_enable => '1' --! Clock enable input for D-Flip-Flops
        );
    --! delay line No.1
    --! 
    delay_line_inst_1 : ENTITY work.delay_line
        GENERIC MAP(
            g_DL_ELEMENT_COUNT => g_DL_ELEMENT_COUNT/g_DELAY_LINE_COUNT,
            g_LOCATION => "SLICE_X38Y50"
        )
        PORT MAP(
            i_clk => w_clk100, --! Main clock for D-Flip-Flops
            i_trigger_in => w_delay_interconnect(0), --! Input of delay line
            o_loop_out => w_delay_interconnect(1), --! Output of delay line
            o_dff_q => o_dff_q,
            i_D => "0000", --! DI for CARRY4 block
            i_S => "1111", --! S for CARRY4 block
            i_nReset => '1', --! Synchronous reset input for D-Flip-Flops
            i_clock_enable => '1' --! Clock enable input for D-Flip-Flops 
        );

    --! delay line No.2
    --! 
    delay_line_inst_2 : ENTITY work.delay_line
        GENERIC MAP(
            g_DL_ELEMENT_COUNT => g_DL_ELEMENT_COUNT/g_DELAY_LINE_COUNT,
            g_LOCATION => "SLICE_X40Y50"
        )
        PORT MAP(
            i_clk => w_clk100, --! Main clock for D-Flip-Flops
            i_trigger_in => w_delay_interconnect(1), --! Input of delay line
            o_loop_out => w_delay_interconnect(2), --! Output of delay line
            o_dff_q => o_dff_q,
            i_D => "0000", --! DI for CARRY4 block
            i_S => "1111", --! S for CARRY4 block
            i_nReset => '1', --! Synchronous reset input for D-Flip-Flops
            i_clock_enable => '1' --! Clock enable input for D-Flip-Flops 
        );

    --! delay line No.3
    --! 
    delay_line_inst_3 : ENTITY work.delay_line
        GENERIC MAP(
            g_DL_ELEMENT_COUNT => g_DL_ELEMENT_COUNT/g_DELAY_LINE_COUNT,
            g_LOCATION => "SLICE_X42Y50"
        )
        PORT MAP(
            i_clk => w_clk100, --! Main clock for D-Flip-Flops
            i_trigger_in => w_delay_interconnect(2), --! Input of delay line
            o_loop_out => w_delay_interconnect(3), --! Output of delay line
            o_dff_q => o_dff_q,
            i_D => "0000", --! DI for CARRY4 block
            i_S => "1111", --! S for CARRY4 block
            i_nReset => '1', --! Synchronous reset input for D-Flip-Flops
            i_clock_enable => '1' --! Clock enable input for D-Flip-Flops 
        );

    ---------------------------------------------------------    
    --                   reg-state logic                   --
    ---------------------------------------------------------

    ---------------------------------------------------------
    --                  next-state logic                   --
    ---------------------------------------------------------


END rtl;