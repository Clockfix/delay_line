-----------------------------
--! @author Imants Pulkstenis 
--! @date 05.09.2021 
--! @file uart_tx.vhd
--! @version A
--! @copyright Copyright (c) 2021 Imants Pulkstenis
--! 
--! @brief *Project name:* Delay line 
--! *Module name:* UART TX module
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

ENTITY uart_tx IS
    GENERIC (
        g_CLKS_PER_BIT : INTEGER := 868 --! Clocks per one bit '''@115200''' baud and '''@100MHz''' clock
    );
    PORT (
        i_clk : IN STD_LOGIC; --! input clock
        i_TX_DV : IN STD_LOGIC; --! TX input data valid
        i_TX_Byte : IN STD_LOGIC_VECTOR(7 DOWNTO 0); --! Input byte
        o_TX_Active : OUT STD_LOGIC; --! active transmission
        o_TX_line : OUT STD_LOGIC; --! TX output line
        o_TX_Done : OUT STD_LOGIC --! Transmission done
    );
END uart_tx; --! UART RX entity

ARCHITECTURE rtl OF uart_tx IS

    --! User-Defined Type for State Machine
    TYPE t_state IS
    (
    FSM_IDLE,
    FSM_TX_START_BIT,
    FSM_TX_DATA_BITS,
    FSM_TX_STOP_BIT,
    FSM_CLEANUP
    );

    --! Defining FSM states
    SIGNAL r_state_reg, r_state_next : t_state := FSM_IDLE;
    --! Clock counter
    SIGNAL r_clock_count_reg, r_clock_count_next : UNSIGNED(log2c(g_CLKS_PER_BIT + 1) - 1 DOWNTO 0) := (OTHERS => '0');
    --! Index of bit - 8 bits total
    SIGNAL r_bit_index_reg, r_bit_index_next : UNSIGNED(2 DOWNTO 0) := (OTHERS => '0');
    --! Received byte
    SIGNAL r_tx_byte_reg, r_tx_byte_next : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
    --! Transmission done
    SIGNAL r_tx_done_reg, r_tx_done_next : STD_LOGIC := '0';
    --! Transmission now active
    SIGNAL r_tx_active_reg, r_tx_active_next : STD_LOGIC := '0';
    --! Transmission line register
    SIGNAL r_tx_line_reg, r_tx_line_next : STD_LOGIC := '0';
    --! Clock counter reset wire
    SIGNAL w_clock_counter_reset : STD_LOGIC;
    --! Clock counter enable
    SIGNAL w_clock_counter_enable : STD_LOGIC;

BEGIN

    ---------------------------------------------------------
    --                       outputs                       --
    --------------------------------------------------------- 

    o_TX_Active <= r_tx_active_reg; --! active transmission
    o_TX_line <= r_tx_line_reg; --! TX output line
    o_TX_Done <= r_tx_done_reg; --! Transmission done

    ---------------------------------------------------------    
    --                   reg-state logic                   --
    ---------------------------------------------------------
    --! Register state logic 
    reg_state : PROCESS
    BEGIN
        WAIT UNTIL rising_edge(i_clk);
        r_state_reg <= r_state_next;
        IF w_clock_counter_reset = '0' THEN
            IF w_clock_counter_enable = '1' THEN
                r_clock_count_reg <= r_clock_count_next;
            END IF;
        ELSE
            r_clock_count_reg <= (OTHERS => '0');
        END IF;
        r_bit_index_reg <= r_bit_index_next;
        r_tx_byte_reg <= r_tx_byte_next;
        r_tx_done_reg <= r_tx_done_next;
        r_tx_active_reg <= r_tx_active_next;
        r_tx_line_reg <= r_tx_line_next;
    END PROCESS;

    ---------------------------------------------------------
    --                  next-state logic                   --
    ---------------------------------------------------------
    --! Finite State Machine main precess
    uart_tx_fsm : PROCESS (ALL)
    BEGIN
        r_clock_count_next <= r_clock_count_reg + 1;
        CASE (r_state_reg) IS
            WHEN FSM_IDLE => --! Waiting start of transmission 
                w_clock_counter_reset <= '1';
                w_clock_counter_enable <= '0';
                r_tx_done_next <= '0';
                r_bit_index_next <= (OTHERS => '0');
                IF i_tx_dv = '1' THEN -- Start bit detected
                    r_state_next <= FSM_TX_START_BIT;
                    r_tx_active_next <= '1';
                    r_tx_byte_next <= i_TX_Byte;
                    r_tx_line_next <= '0'; --! Start bit = 0
                ELSE
                    r_state_next <= FSM_IDLE;
                    r_tx_active_next <= '0';
                    r_tx_byte_next <= r_tx_byte_reg;
                    r_tx_line_next <= '1'; --! Start bit = 0
                END IF;
            WHEN FSM_TX_START_BIT => --! Send out Start Bit. Start bit = 0
                r_tx_line_next <= '0';
                r_tx_active_next <= '1';
                r_tx_done_next <= '0';
                r_bit_index_next <= r_bit_index_reg;
                r_tx_byte_next <= r_tx_byte_reg;
                IF r_clock_count_reg < g_CLKS_PER_BIT - 1 THEN
                    w_clock_counter_reset <= '0';
                    w_clock_counter_enable <= '1';
                    r_state_next <= FSM_TX_START_BIT;
                ELSE
                    w_clock_counter_reset <= '1';
                    w_clock_counter_enable <= '0';
                    r_state_next <= FSM_TX_DATA_BITS;
                END IF;
            WHEN FSM_TX_DATA_BITS => --! Send out Start Bit. Start bit = 0
                r_tx_line_next <= r_tx_byte_reg(to_integer(r_bit_index_reg)); --! outputs bit on TX line
                r_tx_active_next <= '1';
                r_tx_done_next <= '0';
                r_tx_byte_next <= r_tx_byte_reg;
                IF r_clock_count_reg < g_CLKS_PER_BIT - 1 THEN
                    w_clock_counter_reset <= '0';
                    w_clock_counter_enable <= '1';
                    r_state_next <= FSM_TX_DATA_BITS;
                    r_bit_index_next <= r_bit_index_reg;
                ELSE
                    w_clock_counter_reset <= '1';
                    w_clock_counter_enable <= '0';
                    IF r_bit_index_reg < 7 THEN --! Check if we have sent out all bits
                        r_state_next <= FSM_TX_DATA_BITS;
                        r_bit_index_next <= r_bit_index_reg + 1;
                    ELSE
                        r_state_next <= FSM_TX_STOP_BIT;
                        r_bit_index_next <= (OTHERS => '0');
                    END IF;
                END IF;
            WHEN FSM_TX_STOP_BIT => --! Send out Stop bit.  Stop bit = 1
                r_tx_line_next <= '1';
                r_tx_byte_next <= r_tx_byte_reg;
                r_bit_index_next <= r_bit_index_reg;
                IF r_clock_count_reg < g_CLKS_PER_BIT - 1 THEN
                    w_clock_counter_reset <= '0';
                    w_clock_counter_enable <= '1';
                    r_tx_active_next <= '1';
                    r_tx_done_next <= '0';
                    r_state_next <= FSM_TX_STOP_BIT;
                ELSE
                    w_clock_counter_reset <= '1';
                    w_clock_counter_enable <= '0';
                    r_tx_active_next <= '0';
                    r_tx_done_next <= '1';
                    r_state_next <= FSM_CLEANUP;
                END IF;
            WHEN FSM_CLEANUP =>
                r_state_next <= FSM_IDLE;
                r_tx_done_next <= '0';
                r_tx_active_next <= '0';
                r_tx_line_next <= '1';
                r_tx_byte_next <= r_tx_byte_reg;
                r_bit_index_next <= (OTHERS => '0');
                w_clock_counter_reset <= '1';
                w_clock_counter_enable <= '0';
            WHEN OTHERS => --! Undefined state
                w_clock_counter_reset <= '1';
                w_clock_counter_enable <= '0';
                r_state_next <= FSM_IDLE;
                r_tx_active_next <= '0';
                r_bit_index_next <= (OTHERS => '0');
                r_tx_byte_next <= r_tx_byte_reg;
                r_tx_done_next <= '0';
                r_tx_active_next <= '0';
                r_tx_line_next <= '1';
        END CASE;
    END PROCESS;

END rtl;