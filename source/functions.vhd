-----------------------------
--! @author  Rihards Novickis
--! @date - 30.09.2020 
--! @brief Project name -  Generic function
--! @file functions.vhd
--! @version A
--! @details Module name - Calculate LOG2
--! Function usage:
--!         log2c(MAX_VALUE + 1)
--! Example:
--!         led_out : OUT std_logic_vector(log2c(MAX_VALUE + 1) - 1 DOWNTO 0);
--!
--! Do not forget add '''work.functions.all''' in VHDL file where function is used
--! 
--! Revision:
--! A - initial design
--! B - 
--!
-----------------------------
LIBRARY ieee; --always use this library
USE ieee.std_logic_1164.ALL; --always use this library
USE ieee.numeric_std.ALL; --use this library if arithmetic require

PACKAGE functions IS
    FUNCTION log2c(input : INTEGER) RETURN INTEGER;
END PACKAGE;

PACKAGE BODY functions IS
    FUNCTION log2c(input : INTEGER) RETURN INTEGER IS
        VARIABLE temp, log : INTEGER;
    BEGIN
        temp := input - 1;
        log := 0;
        WHILE (temp > 0) LOOP
            temp := temp/2;
            log := log  + 1;
        END LOOP;
        RETURN log;
    END FUNCTION log2c;
END PACKAGE BODY;