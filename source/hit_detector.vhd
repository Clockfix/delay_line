-----------------------------
--! Author Imants Pulkstenis
--! Date 05.03.2020
--! Project name: Delay line 
--! Module name: Hit detector
--!
--! Detailed module description:
--! 
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
LIBRARY UNISIM; -- Xilinx primitive
USE UNISIM.vcomponents.ALL; -- Xilinx primitive

ENTITY hit_detector IS
    PORT (
        i_clk : IN STD_LOGIC; --! Main clock
        i_first_delay : IN STD_LOGIC; --!  Trigger form first element of delay line
        i_last_delay : IN STD_LOGIC; --!  Trigger form first element of delay line
        i_enable : IN STD_LOGIC; --! Enable hit detector logic
        o_hit_detected : OUT STD_LOGIC --! HIGH when hit is detected
    );
END hit_detector;

ARCHITECTURE rtl OF hit_detector IS
   
    ATTRIBUTE keep : STRING;
    ATTRIBUTE keep OF i_clk : SIGNAL IS "true";
    ATTRIBUTE keep OF o_hit_detected : SIGNAL IS "true";
    ATTRIBUTE keep OF i_enable : SIGNAL IS "true";
    ATTRIBUTE keep OF i_first_delay : SIGNAL IS "true";
    ATTRIBUTE keep OF i_last_delay : SIGNAL IS "true";

    SIGNAL w_AND_product : STD_LOGIC;   --! AND product from first delay and NOT last delay
    SIGNAL w_trigger_Q : STD_LOGIC; --! Output form D-Flip-Flop

BEGIN 
 
    ---------------------------------------------------------    
    --                   reg-state logic                   --
    ---------------------------------------------------------

    w_AND_product <= i_first_delay AND (NOT i_last_delay); -- AND gate

    ---------------------------------------------------------
    --                  next-state logic                   --
    ---------------------------------------------------------
    
    --! FDRE: Single Data Rate D Flip-Flop with Synchronous Reset and
    --! Clock Enable (pos_edge clk).
    --! 7 Series
    --! Xilinx HDL Libraries Guide, version 2012.2
    FDRE_trigger : FDRE
    PORT MAP(
        Q => w_trigger_Q, --! Data output
        C => i_clk, --! Clock input
        CE => i_enable, --! Clock enable input
        R => '0', --! Synchronous reset input, active HIGH
        D => w_AND_product --! Data input
    );
    ---------------------------------------------------------
    --                       outputs                       --
    --------------------------------------------------------- 

    o_hit_detected <= w_trigger_Q;

END rtl;