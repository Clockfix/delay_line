-----------------------------
--! @author Imants Pulkstenis
--! @date 18.03.2020
--! @file monostable_ff.vhd
--! @version A
--! @copyright Copyright (c) 2021 Imants Pulkstenis
--! 
--! @brief Project name: Delay line
--! Module name: Mono Stable Flip Flop 
--! 
--! @details Mono Stable Flip Flop are based on D-FlipFlop and buffers/inverters 
--! -------------------------------------------------------------
--! **Revision:**
--! A - initial design
--! B - 
--! C - 
--! -----------------------------

LIBRARY IEEE; --always use this library
USE IEEE.std_logic_1164.ALL; --always use this library
LIBRARY UNISIM; -- Xilinx primitive
USE UNISIM.vcomponents.ALL; -- Xilinx primitive

ENTITY monostable_ff IS
    GENERIC (
        g_DELAY_ELEMENTS : INTEGER := 4 --! delay element count that will reset D-Flip Flop. The CLR for D-FlipFlop is active high so delay must be even number.
    );
    PORT (
        i : IN STD_LOGIC; --! buffer/inverter Input 
        o : OUT STD_LOGIC --! buffer/inverter Output 
    );
END monostable_ff;

ARCHITECTURE rtl OF monostable_ff IS

    SIGNAL w_buffer : STD_LOGIC_VECTOR(g_DELAY_ELEMENTS DOWNTO 0); --! inputs and outputs of buffers or inverters  

BEGIN

    ---------------------------------------------------------    
    --                   reg-state logic                   --
    ---------------------------------------------------------

    --! FDCE: Single Data Rate D Flip-Flop with Asynchronous Clear and
    --! Clock Enable (posedge clk).
    --! 7 Series
    --! Xilinx HDL Libraries Guide, version 14.1
    FDCE_inst : FDCE
    GENERIC MAP(
        INIT => '0') --! Initial value of register ('0' or '1')
    PORT MAP(
        Q => w_buffer(0), --! Data output
        C => i, --! Clock input
        CE => '1', --! Clock enable input    
        CLR => w_buffer(g_DELAY_ELEMENTS), --! Asynchronous clear input
        D => w_buffer(1) --! Data input
    );
    -- End of FDCE_inst instantiation

    ---------------------------------------------------------
    --                  next-state logic                   --
    ---------------------------------------------------------

    inverter_gen : FOR I IN 1 TO g_DELAY_ELEMENTS GENERATE inverter_inst : ENTITY work.buffer_inverter
        GENERIC MAP(
            g_INIT => "01" --! Binary number assigned to the INIT attribute. Default value "10" that configures this LUT1 as buffer
        )
        PORT MAP(
            i => w_buffer(I - 1), --! buffer/inverter Input 
            o => w_buffer(I) --! buffer/inverter Output
        );
    END GENERATE;


    ---------------------------------------------------------
    --                       outputs                       --
    --------------------------------------------------------- 

    o <= w_buffer(0);
END rtl;