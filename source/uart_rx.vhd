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

ENTITY uart_rx IS
    GENERIC (
        g_CLKS_PER_BIT : INTEGER := 868 --! Clocks per one bit '''@115200''' baud and '''@100MHz''' clock
    );
    PORT (

        i_clk : IN STD_LOGIC; --! input clock
        i_rx_line : IN STD_LOGIC; --! RX input line
        o_rx_byte : OUT STD_LOGIC_VECTOR(7 DOWNTO 0); --! Outputs received byte
        o_rx_data_valid : OUT STD_LOGIC --! Data valid on output
    );
END uart_rx; --! UART TX entity

ARCHITECTURE rtl OF uart_rx IS

    --! User-Defined Type for State Machine
    TYPE t_state IS
    (
    FSM_IDLE,
    FSM_RX_START_BIT,
    FSM_RX_DATA_BITS,
    FSM_RX_STOP_BIT,
    FSM_CLEANUP
    );

    --! Defining FSM states
    SIGNAL r_state_reg, r_state_next : t_state := FSM_IDLE;
    --! Clock counter
    SIGNAL r_clock_count_reg, r_clock_count_next : UNSIGNED(log2c(g_CLKS_PER_BIT + 1) - 1 DOWNTO 0) := (OTHERS => '0');
    --! Index of bit - 8 bits total
    SIGNAL r_bit_index_reg, r_bit_index_next : UNSIGNED(2 DOWNTO 0) := (OTHERS => '0');
    --! Received byte
    SIGNAL r_rx_byte_reg, r_rx_byte_next : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
    --! Data valid register
    SIGNAL r_rx_dv_reg, r_rx_dv_next : STD_LOGIC := '0';
    --! Clock counter reset wire
    SIGNAL w_clock_counter_reset : STD_LOGIC;
    --! Clock counter enable
    SIGNAL w_clock_counter_enable : STD_LOGIC;

BEGIN

    ---------------------------------------------------------
    --                       outputs                       --
    --------------------------------------------------------- 

    o_rx_data_valid <= r_rx_dv_reg;
    o_rx_byte <= r_rx_byte_reg;

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
        r_rx_byte_reg <= r_rx_byte_next;
        r_rx_dv_reg <= r_rx_dv_next;
    END PROCESS;

    -- reg_clock_counter : PROCESS
    -- BEGIN
    --     IF w_clock_counter_reset = '1' THEN
    --         r_clock_count_reg <= (OTHERS => '0');
    --     ELSE
    --         IF w_clock_counter_enable = '1' AND rising_edge(i_clk) THEN
    --             r_clock_count_reg <= r_clock_count_next;
    --         END IF;
    --     END IF;
    -- END PROCESS;

    ---------------------------------------------------------
    --                  next-state logic                   --
    ---------------------------------------------------------
    --! Finite State Machine main precess
    uart_rx_fsm : PROCESS (ALL)
    BEGIN
        r_clock_count_next <= r_clock_count_reg + 1;
        CASE (r_state_reg) IS
            WHEN FSM_IDLE => --! Waiting start of transmission 
                w_clock_counter_reset <= '1';
                w_clock_counter_enable <= '0';
                r_rx_dv_next <= '0';
                r_bit_index_next <= (OTHERS => '0');
                r_rx_byte_next <= r_rx_byte_reg;
                IF (i_rx_line = '0') THEN -- Start bit detected
                    r_state_next <= FSM_RX_START_BIT;
                ELSE
                    r_state_next <= FSM_IDLE;
                END IF;
            WHEN FSM_RX_START_BIT => --! Check middle of start bit to make sure it's still low
                IF r_clock_count_reg = (g_CLKS_PER_BIT)/2 THEN
                    IF (i_rx_line = '0') THEN
                        r_state_next <= FSM_RX_DATA_BITS;
                    ELSE
                        r_state_next <= FSM_IDLE; --! Start bit not LOW anymore
                    END IF;
                    w_clock_counter_reset <= '1'; --! reset counter, found the middle of the bit
                ELSE
                    w_clock_counter_reset <= '0';
                    r_state_next <= FSM_RX_START_BIT;
                END IF;
                r_rx_byte_next <= r_rx_byte_reg;
                r_bit_index_next <= r_bit_index_reg;
                r_rx_dv_next <= '0';
                w_clock_counter_enable <= '1';
            WHEN FSM_RX_DATA_BITS => --! Wait CLKS_PER_BIT-1 clock cycles to sample serial data
                IF r_clock_count_reg < g_CLKS_PER_BIT - 1 THEN
                    w_clock_counter_reset <= '0';
                    r_state_next <= FSM_RX_DATA_BITS;
                    r_rx_byte_next <= r_rx_byte_reg;
                    r_bit_index_next <= r_bit_index_reg;
                ELSE
                    w_clock_counter_reset <= '1';
                    r_rx_byte_next <= r_rx_byte_reg;
                    r_rx_byte_next(to_integer(r_bit_index_reg)) <= i_rx_line; --! saving received bit
                    IF r_bit_index_reg < 7 THEN --! Check if we have received all bits
                        r_bit_index_next <= r_bit_index_reg + 1;
                        r_state_next <= FSM_RX_DATA_BITS;
                    ELSE
                        r_bit_index_next <= (OTHERS => '0'); --! return bit index to initial value
                        r_state_next <= FSM_RX_STOP_BIT;
                    END IF;
                END IF;
                r_rx_dv_next <= '0';
                w_clock_counter_enable <= '1';
            WHEN FSM_RX_STOP_BIT => --! Receive Stop bit.  Stop bit = 1
                IF r_clock_count_reg < g_CLKS_PER_BIT - 1 THEN
                    w_clock_counter_reset <= '0';
                    r_state_next <= FSM_RX_STOP_BIT;
                    r_rx_dv_next <= '0';
                ELSE
                    r_rx_dv_next <= '1';
                    w_clock_counter_reset <= '1';
                    r_state_next <= FSM_CLEANUP;
                END IF;
                r_rx_byte_next <= r_rx_byte_reg;
                r_bit_index_next <= r_bit_index_reg;
                w_clock_counter_enable <= '1';
            WHEN FSM_CLEANUP => --! Stay here 1 clock cycle
                r_rx_dv_next <= '0';
                r_rx_byte_next <= r_rx_byte_reg;
                r_bit_index_next <= r_bit_index_reg;
                r_state_next <= FSM_IDLE;
                w_clock_counter_reset <= '1';
                w_clock_counter_enable <= '0';
            WHEN OTHERS => --! Undefined state
                r_state_next <= FSM_IDLE;
                r_rx_dv_next <= r_rx_dv_reg;
                w_clock_counter_reset <= '1';
                r_bit_index_next <= r_bit_index_reg;
                r_rx_byte_next <= r_rx_byte_reg;
                w_clock_counter_enable <= '0';
        END CASE;
    END PROCESS;
END rtl;