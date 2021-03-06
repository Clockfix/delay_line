-----------------------------
-- Author Imants Pulkstenis
-- Date 05.03.2020
-- Project name: Delay line
-- Module name: Encoder module 
--
-- Detailed module description:
-- 
-- Converts thermometer code to binary.
-- Since the fine time result is in a thermometer code , the output
-- of the encoder is generated according to the position of ‘1-0’ transition.
--
-- Revision:
-- A - initial design
-- B - 
--
-----------------------------
LIBRARY IEEE; --always use this library
--USE ieee.std_logic_unsigned.ALL; --extends the std_logic_arith library
--USE ieee.std_logic_arith.ALL; --basic arithmetic operations for representing integers in standard ways
USE IEEE.numeric_std.ALL; --use this library if arithmetic required
USE IEEE.std_logic_1164.ALL; --always use this library

--define connections to outside
ENTITY encoder IS
    GENERIC (
        g_dl_element_count : INTEGER := 4;
        g_fine_time_data_width : INTEGER := 8
    );
    PORT (
        i_clk : IN STD_LOGIC; -- input clock
        i_therm_code : IN STD_LOGIC_VECTOR(g_dl_element_count - 1 DOWNTO 0);
        o_fine_time : OUT STD_LOGIC_VECTOR(g_fine_time_data_width - 1 DOWNTO 0)--;
        --S : IN std_logic_vector(3 DOWNTO 0)
    );
END encoder;
--define inside of the module
ARCHITECTURE behavioral OF encoder IS
    --define components to use
    ATTRIBUTE keep : STRING;
    ATTRIBUTE keep OF i_clk : SIGNAL IS "true";
    ATTRIBUTE keep OF i_therm_code : SIGNAL IS "true";
    ATTRIBUTE keep OF o_fine_time : SIGNAL IS "true";

    SIGNAL w_edge_code : STD_LOGIC_VECTOR(g_dl_element_count - 2 DOWNTO 0); -- this code will contain '1' where 1-0 or 0-1 is detected

BEGIN --define the operation of the module!

    CARRY4_gen : FOR I IN 0 TO (g_dl_element_count - 2) GENERATE
        w_edge_code(I) <= i_therm_code(I) XOR i_therm_code(I + 1);
    END GENERATE;

    PROCESS (w_edge_code)
        VARIABLE v_count_null : unsigned(g_fine_time_data_width - 1 DOWNTO 0) := (OTHERS => '0');
        VARIABLE v_position : unsigned(g_fine_time_data_width - 1 DOWNTO 0) := (OTHERS => '0');
    BEGIN
        v_count_null := (OTHERS => '0'); --initialize count variable.
        v_position := (OTHERS => '0'); --initialize position variable.
        FOR i IN 0 TO g_dl_element_count - 2 LOOP --check for all the bits.
            IF (w_edge_code(i) = '0') THEN --check if the bit is '1'
                v_count_null := v_count_null + 1; --if its zero, increment the count.
            ELSE
                v_position := v_count_null; --if its one, then save value in this variable
            END IF;
        END LOOP;
        o_fine_time <= STD_LOGIC_VECTOR(v_position); --assign the count to output.
    END PROCESS;
END behavioral;