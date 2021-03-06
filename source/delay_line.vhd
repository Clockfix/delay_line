-----------------------------
--! @author Imants Pulkstenis
--! @date 18.03.2021
--! @file delay_line.vhd
--! @version C
--! @copyright Copyright (c) 2021 Imants Pulkstenis
--! 
--! @brief Project name: Delay line
--! Module name: Delay line module 
--! 
--! @details Delay line module for Xilinx 7 series. Its length can be configurable from the top module.
--! The Delay line consists of MUXes(CARRY4 primitives) and D flip Flops at the output.
--! -------------------------------------------------------------
--! ***CARRY4*** (description from *Xilinx 7 Series FPGA Libraries Guide for HDL Designs*)
--! Primitive: Fast Carry Logic with Look Ahead
--!     **Introduction**
--! This circuit design represents the fast carry logic for a slice. The carry chain consists of a series of four MUXes
--! and four XORs that connect to the other logic (LUTs) in the slice via dedicated routes to form more complex
--! functions. The fast carry logic is useful for building arithmetic functions like adders, counters, subtractors and
--! add/subs, as well as such other logic functions as wide comparators, address decoders, and some logic gates
--! (specifically, AND and OR).
--!    **Port Descriptions**
--! ```
--!      |  Port  | Direction | Width |                  Function                  |
--!      | ------ | --------- | ----- | ------------------------------------------ |
--!      | O      | Output    | 4     | Carry chain XOR general data out           |
--!      | CO     | Output    | 4     | Carry-out of each stage of the carry chain |
--!      | DI     | Input     | 4     | Carry-MUX data input                       |
--!      | S      | Input     | 4     | Carry-MUX select line                      |
--!      | CYINIT | Input     | 1     | Carry-in initialization input              |
--!      | CI     | Input     | 1     | Carry cascade input                        |
--! ```  
--! -------------------------------------------------------------
--! **Revision:**
--! A - initial design
--! B - Long delay line test without D-Flip-Flops
--! C - Add XOR output and nReset input
--! D - 
--! -----------------------------
LIBRARY IEEE; --always use this library
USE ieee.std_logic_unsigned.ALL; --extends the std_logic_arith library
USE ieee.std_logic_arith.ALL; --basic arithmetic operations for representing integers in standard ways
USE IEEE.numeric_std.ALL; --use this library if arithmetic required
USE IEEE.std_logic_1164.ALL; --always use this library
LIBRARY UNISIM; -- Xilinx primitive
USE UNISIM.vcomponents.ALL; -- Xilinx primitive

ENTITY delay_line IS
    GENERIC (
        g_DL_ELEMENT_COUNT : INTEGER := 16; --! Count of delay elements in the module. Four delay elements are in one CARRY4 primitive. The minimal number of CARRY4 blocks are 2, e.i. minimal delay element count are 2*4=8. 
        g_LOCATION : STRING := "SLICE_X1Y1" --! Location of the first CARRY4 block
    );
    PORT (
        i_clk : IN STD_LOGIC;   --! Main clock for D-Flip-Flops
        i_trigger_in : IN STD_LOGIC; --! Input of delay line
        o_dff_q : OUT STD_LOGIC_VECTOR(g_DL_ELEMENT_COUNT - 1 DOWNTO 0); -- thermometer time code
        i_D : IN STD_LOGIC_VECTOR(3 DOWNTO 0); --! DI for CARRY4 block
        i_S : IN STD_LOGIC_VECTOR(3 DOWNTO 0); --! S for CARRY4 block
        o_loop_out : OUT STD_LOGIC; --! Output of delay line
        i_nReset : IN std_logic; --! Synchronous reset input for D-Flip-Flops
        i_clock_enable: IN std_logic --! Clock enable input for D-Flip-Flops
    );
END delay_line;

--define inside of the module
ARCHITECTURE rtl OF delay_line IS
    --define components to use
    SIGNAL w_CO : STD_LOGIC_VECTOR(g_DL_ELEMENT_COUNT - 1 DOWNTO 0) := (OTHERS => '0'); --! CO vector from Carry-out of each stage of the carry chain
    SIGNAL w_O : STD_LOGIC_VECTOR(g_DL_ELEMENT_COUNT - 1 DOWNTO 0) := (OTHERS => '0'); --! CO vector from Carry-out of each stage of the carry chain

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
    ATTRIBUTE keep OF i_trigger_in : SIGNAL IS "true";
    ATTRIBUTE keep OF w_CO : SIGNAL IS "true";
    ATTRIBUTE keep OF w_O : SIGNAL IS "true";
    ATTRIBUTE keep OF o_dff_q : SIGNAL IS "true";
BEGIN

    --------------------------------------------------------------------------
    --! CARRY4: Fast Carry Logic Component
    --! 7 Series
    --! Xilinx HDL Libraries Guide, version 2012.2 
    CARRY4_first : CARRY4 PORT MAP(
        CO => w_CO(3 DOWNTO 0), --! 4-bit carry out
        O => w_O(3 DOWNTO 0), --! 4-bit carry chain XOR data out
        CI => '0', --! 1-bit carry cascade input 
        CYINIT => i_trigger_in, --! 1-bit carry initialization
        DI => i_D, --! 4-bit carry-MUX data in
        S => i_S --! 4-bit carry-MUX select input
    );
    CARRY4_gen : FOR I IN 1 TO (g_DL_ELEMENT_COUNT/4) - 2 GENERATE CARRY4_inst_next : COMPONENT CARRY4
        PORT MAP(
            CO => w_CO(I * 4 + 3 DOWNTO I * 4), -- 4-bit carry out
            O => w_O(I * 4 + 3 DOWNTO I * 4), -- 4-bit carry chain XOR data out
            CI => w_CO(I * 4 - 1), -- 1-bit carry cascade input 
            CYINIT => '0', -- 1-bit carry initialization
            DI => i_D, -- 4-bit carry-MUX data in
            S => i_S -- 4-bit carry-MUX select input
        );
    END GENERATE;
    --! CARRY4: Fast Carry Logic Component
    CARRY4_last : CARRY4 PORT MAP(
        CO => w_CO(g_DL_ELEMENT_COUNT - 1 DOWNTO g_DL_ELEMENT_COUNT - 4), -- 4-bit carry out
        O => w_O(g_DL_ELEMENT_COUNT - 1 DOWNTO g_DL_ELEMENT_COUNT - 4), -- 4-bit carry chain XOR data out
        CI => w_CO(g_DL_ELEMENT_COUNT - 4 - 1), -- 1-bit carry cascade input 
        CYINIT => '0', -- 1-bit carry initialization
        DI => i_D, -- 4-bit carry-MUX data in
        S => i_S -- 4-bit carry-MUX select input
    );
    -- End_of_CARRY4_inst instantiation
    ---------------------------------------------------------------------------

    ---------------------------------------------------------------------------
    --! FDRE: Single Data Rate D Flip-Flop with Synchronous Reset and
    --! Clock Enable (pos_edge clk).
    --! 7 Series
    --! Xilinx HDL Libraries Guide, version 2012.2
    DFF_CO_gen : FOR I IN 0 TO g_DL_ELEMENT_COUNT - 1 GENERATE FDRE_inst : COMPONENT FDRE
        generic map (
            INIT => '0') --! Initial value of register ('0' or '1')
        PORT MAP(
            Q => o_dff_q(I), --! Data output
            C => i_clk, --! Clock input
            CE => i_clock_enable, --! Clock enable input
            R => i_nReset, --! Synchronous reset input
            D => w_CO(I) --! Data input
        );
    END GENERATE;
    -- End of FDRE_inst instantiation
    --------------------------------------------------------------------------------

    ---------------------------------------------------------------------------
    --! FDRE: Single Data Rate D Flip-Flop with Synchronous Reset and
    --! Clock Enable (pos_edge clk).
    --! 7 Series
    --! Xilinx HDL Libraries Guide, version 2012.2
    DFF_O_gen : FOR I IN 0 TO g_DL_ELEMENT_COUNT - 1 GENERATE FDRE_inst : COMPONENT FDRE
        generic map (
            INIT => '0') --! Initial value of register ('0' or '1')
        PORT MAP(
          --  Q => o_dff_q(I), --! Data output
            C => i_clk, --! Clock input
            CE => i_clock_enable, --! Clock enable input
            R => i_nReset, --! Synchronous reset input
            D => w_O(I) --! Data input
        );
    END GENERATE;
    -- End of FDRE_inst instantiation
    --------------------------------------------------------------------------------


    o_loop_out <= w_CO(g_DL_ELEMENT_COUNT - 1); --! last element of delay line

END rtl;