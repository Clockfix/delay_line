-----------------------------
--! @author Imants Pulkstenis 
--! @date 05.09.2021 
--! @file uart_loopback.vhd
--! @version A
--! @copyright Copyright (c) 2021 Imants Pulkstenis
--! 
--! @brief *Project name:* Delay line 
--! *Module name:* UART loopback module
--! 
--! @details *Detailed description*:
--! Set Parameter CLKS_PER_BIT as follows:
--! CLKS_PER_BIT = (Frequency of i_Clock)/(Frequency of UART)
--! Example: 100 MHz Clock, 115200 baud UART
--! (100_000_000)/(115200) = 868
--! **Revision:**
--! A - initial design  
--! B - 
--! C - 
--! D -
LIBRARY IEEE; --always use this library
USE IEEE.std_logic_unsigned.ALL; --extends the std_logic_arith library
--USE IEEE.std_logic_arith.ALL; --basic arithmetic operations for representing integers in standard ways
USE IEEE.numeric_std.ALL; --use this library if arithmetic required
USE IEEE.std_logic_1164.ALL; --always use this library
USE work.functions.ALL;

ENTITY uart_loopback IS
    GENERIC (
        g_CLKS_PER_BIT : INTEGER := 86 --! Clocks per one bit '''@115200''' baud and '''@100MHz''' clock
    );
    PORT (
        i_clk : IN STD_LOGIC; --! input clock
        i_rx_line : IN STD_LOGIC; --! RX input line
        o_tx_line : OUT STD_LOGIC; --! TX output line
        o_rx_byte : OUT STD_LOGIC_VECTOR(7 DOWNTO 0); --! Outputs received byte
        i_tx_byte : in STD_LOGIC_VECTOR(7 DOWNTO 0); --! Outputs received byte
        o_rx_data_valid : OUT STD_LOGIC; --! Data valid on output
        i_tx_dv : IN STD_LOGIC; --! TX input data valid
        o_tx_Active : OUT STD_LOGIC; --! active transmission
        o_tx_Done : OUT STD_LOGIC --! Transmission done
    );
END uart_loopback; --! UART TX entity

ARCHITECTURE rtl OF uart_loopback IS

BEGIN

    ---------------------------------------------------------
    --                       outputs                       --
    --------------------------------------------------------- 

    ---------------------------------------------------------    
    --             instantiate sub entities                --
    ---------------------------------------------------------
    --! UART RX entity
    uart_rx_inst : ENTITY work.uart_rx
        GENERIC MAP(
            g_CLKS_PER_BIT => g_CLKS_PER_BIT --! Clocks per one bit "86" @ 10MHz
        )
        PORT MAP(
            i_clk => i_clk, --! input clock
            i_rx_line => i_rx_line, --! RX input line
            o_rx_byte => o_rx_byte, --! Outputs received byte
            o_rx_data_valid => o_rx_data_valid --! Data valid on output
        );

    --! UART TX entity
    uart_tx_inst : ENTITY work.uart_tx
        GENERIC MAP(
            g_CLKS_PER_BIT => g_CLKS_PER_BIT --! Clocks per one bit "86" @ 10MHz
        )
        PORT MAP(
            i_clk => i_clk, --! input clock
            i_tx_dv => i_tx_dv, --! TX input data valid
            i_tx_byte => i_tx_byte, --! Input byte
            o_tx_Active => o_tx_Active, --! active transmission
            o_tx_Done => o_tx_Done, --! Transmission done
            o_tx_line => o_tx_line --! TX output line
        );

    ---------------------------------------------------------    
    --                   reg-state logic                   --
    ---------------------------------------------------------
    ---------------------------------------------------------
    --                  next-state logic                   --
    ---------------------------------------------------------

END rtl;