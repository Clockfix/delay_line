-----------------------------
--! @author Imants Pulkstenis 
--! @date 24.08.2021 
--! @file cmod_a7_test.vhd
--! @version A
--! @copyright Copyright (c) 2021 Imants Pulkstenis
--! 
--! @brief *Project name:* Delay line 
--! *Module name:* Cmod A7 board test top entity
--! 
--! @details *Detailed description*:
--! (no description)
--! **Revision:**
--! A - initial design  
--! B - 
--! C - 
--! D -

LIBRARY IEEE; --always use this library
USE IEEE.std_logic_unsigned.ALL; --extends the std_logic_arith library
USE IEEE.std_logic_arith.ALL; --basic arithmetic operations for representing integers in standard ways
--USE IEEE.numeric_std.ALL; --use this library if arithmetic required
USE IEEE.std_logic_1164.ALL; --always use this library

ENTITY cmod_a7_test IS
    PORT (
        -- -- Hardware on Cmod A7 development board
        sysclk : IN STD_LOGIC; --! 12MHz input clock
        led : OUT STD_LOGIC_VECTOR (1 DOWNTO 0); --! Two output LED's
        btn : IN STD_LOGIC_VECTOR (1 DOWNTO 0); --! Two input buttons
        led0_b : OUT STD_LOGIC; --! blue
        led0_g : OUT STD_LOGIC; --! green
        led0_r : OUT STD_LOGIC --! red
    );
END cmod_a7_test; --! Cmod A7 test TOP entity

ARCHITECTURE rtl OF cmod_a7_test IS

    SIGNAL w_clk100 : STD_LOGIC; --! 100MHz main clock 
    SIGNAL r_counter : UNSIGNED(31 DOWNTO 0) := (OTHERS => '0'); --! Counter that controls LED 
    --! locked output from PLL/MMCM 
    SIGNAL w_locked : STD_LOGIC; --! locked output from PLL/MMCM 
    -- ATTRIBUTE keep : STRING;
    -- ATTRIBUTE keep OF w_clk100 : SIGNAL IS "true";

BEGIN

    ---------------------------------------------------------
    --                       outputs                       --
    --------------------------------------------------------- 
    led(1) <= STD_LOGIC(r_counter(24));
    led(0) <= NOT(STD_LOGIC(r_counter(24)));
    led0_b <= NOT(btn(1));
    led0_g <= NOT(w_locked);
    led0_r <= w_locked;

    ---------------------------------------------------------    
    --             instantiate sub entities                --
    ---------------------------------------------------------
    --!  Clock generator entity
    clock_gen_inst : ENTITY work.clock_gen
        PORT MAP(
            i_clk => sysclk, --! Main clock input. For Basys3 board it is 100MHz
            o_clock100 => w_clk100, --; --! In FPGA (PLL/ MMCM ) generated clock
            o_locked => w_locked --, --! locked output from PLL/MMCM 
            -- o_clock10 : OUT STD_LOGIC --! In FPGA (PLL/ MMCM ) generated clock
        );
    ---------------------------------------------------------    
    --                   reg-state logic                   --
    ---------------------------------------------------------
    --!  Counter process
    reg_state_logic : PROCESS (ALL)
    BEGIN
        IF rising_edge(w_clk100) THEN
            r_counter <= r_counter + 1;
        END IF;
    END PROCESS;
    ---------------------------------------------------------
    --                  next-state logic                   --
    ---------------------------------------------------------
END rtl;