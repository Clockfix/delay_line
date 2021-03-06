-----------------------------
--! Author Imants Pulkstenis
--! Date 05.03.2020
--! Project name: Delay line
--! Module name: Delay line module 
--!
--! Detailed module description:
--! Xilinx 7 series delay line module. Its length can be configurable from the top module.
--! The Delay line consists of MUXes and D flip Flops at the output.
--! 
--!
--! Revision:
--! A - initial design
--! B - 
--! C - 
--!
-----------------------------
LIBRARY IEEE; --always use this library
USE ieee.std_logic_unsigned.ALL; --extends the std_logic_arith library
USE ieee.std_logic_arith.ALL; --basic arithmetic operations for representing integers in standard ways
USE IEEE.numeric_std.ALL; --use this library if arithmetic required
USE IEEE.std_logic_1164.ALL; --always use this library
LIBRARY UNISIM; -- Xilinx primitive
USE UNISIM.vcomponents.ALL; -- Xilinx primitive

--define connections to outside
ENTITY delay_line IS
    GENERIC (
        g_DL_ELEMENT_COUNT : INTEGER := 16;
        g_LOCATION : STRING := "SLICE_X1Y1"
    );
    PORT (
        i_clk : IN STD_LOGIC;
        TriggerIn : IN STD_LOGIC;
        DffOut : OUT STD_LOGIC_VECTOR(g_DL_ELEMENT_COUNT - 1 DOWNTO 0); -- thermometer time code
        D : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        S : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        LoopOut : OUT STD_LOGIC--;
        -- nReset : IN std_logic
    );
END delay_line;

--define inside of the module
ARCHITECTURE arch OF delay_line IS
    --define components to use

    SIGNAL CO : STD_LOGIC_VECTOR(g_DL_ELEMENT_COUNT - 1 DOWNTO 0) := (OTHERS => '0');

    -- Preserve the hierarchy of instance CARRY4
    ATTRIBUTE KEEP_HIERARCHY : STRING;
    ATTRIBUTE KEEP_HIERARCHY OF CARRY4_first : LABEL IS "TRUE";
    ATTRIBUTE KEEP_HIERARCHY OF CARRY4_last : LABEL IS "TRUE";

    -- Designates instantiated register instance CARRY4 to be placed
    -- in SLICE site SLICE_X0Y0
    ATTRIBUTE LOC : STRING;
    ATTRIBUTE LOC OF CARRY4_first : LABEL IS g_LOCATION;

    ATTRIBUTE keep : STRING;
    ATTRIBUTE keep OF i_clk : SIGNAL IS "true";
    ATTRIBUTE keep OF TriggerIn : SIGNAL IS "true";
BEGIN --define the operation of the module!

    --------------------------------------------------------------------------
    -- CARRY4: Fast Carry Logic Component
    -- 7 Series
    -- Xilinx HDL Libraries Guide, version 2012.2 
    CARRY4_first : CARRY4 PORT MAP(
        CO => CO(3 DOWNTO 0), -- 4-bit carry out
        -- O => O, -- 4-bit carry chain XOR data out
        CI => '0', -- 1-bit carry cascade input 
        CYINIT => TriggerIn, -- 1-bit carry initialization
        DI => D, -- 4-bit carry-MUX data in
        S => S -- 4-bit carry-MUX select input
    );
    CARRY4_gen : FOR I IN 1 TO (g_DL_ELEMENT_COUNT/4) - 2 GENERATE CARRY4_inst_next : COMPONENT CARRY4
        PORT MAP(
            CO => CO(I * 4 + 3 DOWNTO I * 4), -- 4-bit carry out
            -- O => O, -- 4-bit carry chain XOR data out
            CI => CO(I * 4 - 1), -- 1-bit carry cascade input 
            CYINIT => '0', -- 1-bit carry initialization
            DI => D, -- 4-bit carry-MUX data in
            S => S -- 4-bit carry-MUX select input
        );
    END GENERATE;
    CARRY4_last : CARRY4 PORT MAP(
        CO => CO(g_DL_ELEMENT_COUNT - 1 DOWNTO g_DL_ELEMENT_COUNT - 4), -- 4-bit carry out
        -- O => O, -- 4-bit carry chain XOR data out
        CI => CO(g_DL_ELEMENT_COUNT - 4 - 1), -- 1-bit carry cascade input 
        CYINIT => '0', -- 1-bit carry initialization
        DI => D, -- 4-bit carry-MUX data in
        S => S -- 4-bit carry-MUX select input
    );
    --End_of_CARRY4_inst instantiation
    ---------------------------------------------------------------------------

    ---------------------------------------------------------------------------
    -- FDRE: Single Data Rate D Flip-Flop with Synchronous Reset and
    -- Clock Enable (pos_edge clk).
    -- 7 Series
    -- Xilinx HDL Libraries Guide, version 2012.2
    FDRE_gen : FOR I IN 0 TO g_DL_ELEMENT_COUNT - 1 GENERATE FDRE_inst : COMPONENT FDRE
        PORT MAP(
            Q => DffOut(I), -- Data output
            C => i_clk, -- Clock input
            CE => '1', -- Clock enable input
            R => '0', -- Synchronous reset input
            D => CO(I) -- Data input
        );
    END GENERATE;
    -- End of FDRE_inst instantiation
    --------------------------------------------------------------------------------

    LoopOut <= CO(g_DL_ELEMENT_COUNT - 1); -- last element of delay line

END arch;