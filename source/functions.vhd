-----------------------------
--! Author - Rihards Novickis
--! Date - 30.09.2020 
--! Project name -  
--! Module name - Calculate LOG2
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
            log := log + 1;
        END LOOP;
        RETURN log;
    END FUNCTION log2c;
END PACKAGE BODY;