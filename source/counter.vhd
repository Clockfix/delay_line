-----------------------------
--! Author Imants Pulkstenis
--! Date 06.03.2020
--! Project name: Delay line 
--! Module name: Counter
--!
--! Detailed module description:
--!     Counts how many hits were detected
--!
--! Revision:
--! A - initial design
--! B - 
--!
-----------------------------
LIBRARY IEEE; --always use this library
-- USE ieee.std_logic_unsigned.ALL; --extends the std_logic_arith library
-- USE ieee.std_logic_arith.ALL; --basic arithmetic operations for representing integers in standard ways
USE IEEE.numeric_std.ALL; --use this library if arithmetic required
USE IEEE.std_logic_1164.ALL; --always use this library
-- LIBRARY UNISIM; -- Xilinx primitive
-- USE UNISIM.vcomponents.ALL; -- Xilinx primitive
ENTITY counter IS
    PORT (
        i_clk : IN STD_LOGIC;
        i_hit_detected : IN STD_LOGIC;
        o_counter : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE rtl OF counter IS
    SIGNAL r_count_reg, r_count_next : unsigned(15 DOWNTO 0) := (OTHERS => '0'); --! counter

    ATTRIBUTE keep : STRING;
    ATTRIBUTE keep OF i_hit_detected : SIGNAL IS "true";
BEGIN

    ---------------------------------------------------------    
    --                   reg-state logic                   --
    ---------------------------------------------------------
    reg_state_logic : PROCESS (ALL)
    BEGIN
        IF rising_edge(i_clk) THEN
            IF i_hit_detected THEN
                r_count_reg <= r_count_next;
            END IF;
        END IF;
    END PROCESS;
    ---------------------------------------------------------
    --                  next-state logic                   --
    ---------------------------------------------------------
    r_count_next <= r_count_reg + 1;
    ---------------------------------------------------------
    --                       outputs                       --
    --------------------------------------------------------- 
    o_counter <= STD_LOGIC_VECTOR(r_count_reg(15 DOWNTO 0));
END rtl;