-----------------------------
--! @author Imants Pulkstenis 
--! @date 08.09.2021 
--! @file ram_controller.vhd
--! @version A
--! @copyright Copyright (c) 2021 Imants Pulkstenis
--! 
--! @brief *Project name:* Delay line 
--! *Module name:* RAM controller module
--! 
--! @details *Detailed description*:
--! The Cmod A7 includes 512 KB of Static Random-Access Memory (SRAM). This memory has a standard, easy-to-use
--! parallel interface with 19 address signals, 8 bi-directional data signals, and 3 control signals. The part used is the
--! ISSI IS61WV5128BLL-10BLI. Datasheet: http://www.issi.com/WW/pdf/61-64WV5128Axx-Bxx.pdf
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

ENTITY ram_controller IS
    GENERIC (
        g_CLKS_FOR_SETUP : INTEGER := 3 --! Clock count to wait data setup time
    );
    PORT (
        i_clk : IN STD_LOGIC; --! input clock
        i_read_write : IN STD_LOGIC; --! Select read('0') or write('1')  action
        i_data_valid : IN STD_LOGIC; --! Input data valid (both address and data)
        o_data : OUT STD_LOGIC_VECTOR(7 DOWNTO 0); --! Outputs data
        i_data : IN STD_LOGIC_VECTOR(7 DOWNTO 0); --! Inputs data
        io_ram_data : INOUT STD_LOGIC_VECTOR(7 DOWNTO 0); --! Inputs/outputs data to RAM
        o_ram_address : OUT STD_LOGIC_VECTOR(18 DOWNTO 0); --! Outputs address to RAM
        o_ram_ce_n : OUT STD_LOGIC; --! Chip Enable 
        o_ram_we_n : OUT STD_LOGIC; --! Write Enable 
        o_ram_oe_n : OUT STD_LOGIC; --! Output Enable 
        o_data_valid : OUT STD_LOGIC; --! Data valid on output
        i_address : IN STD_LOGIC_VECTOR(18 DOWNTO 0); --! Input for address(both read and write)
        o_ready : OUT STD_LOGIC --! ready for next read/write
    );
END ram_controller; --! RAM controller entity

ARCHITECTURE rtl OF ram_controller IS

    --! User-Defined Type for State Machine
    TYPE t_state IS
    (
    FSM_IDLE,
    FSM_WRITE,
    FSM_READ,
    FSM_CLEAN
    );

    --! Defining FSM states
    SIGNAL r_state_reg, r_state_next : t_state := FSM_IDLE;
    --! Clock counter
    SIGNAL r_clock_count_reg, r_clock_count_next : UNSIGNED(log2c(g_CLKS_FOR_SETUP + 1) - 1 DOWNTO 0) := (OTHERS => '0');
    --! input data register
    SIGNAL r_input_data_reg : STD_LOGIC_vector (7 DOWNTO 0) := (OTHERS => '0'); -- next state directly connected to input (to RAM)
    --! output data register
    SIGNAL r_output_data_reg , r_output_data_next : STD_LOGIC_vector (7 DOWNTO 0) := (OTHERS => '0'); -- next state directly connected to input (to top entity)
    --! ready register
    SIGNAL r_ready_reg, r_ready_next : STD_LOGIC := '0';
    --! output data valid register
    SIGNAL r_output_data_valid_reg, r_output_data_valid_next : STD_LOGIC := '0';
    --! Address data register
    SIGNAL r_address_reg : std_logic_vector(18 DOWNTO 0) := (OTHERS => '0'); -- next state directly connected to input
    --! RAM Chip enable
    SIGNAL r_ram_ce_reg, r_ram_ce_next : STD_LOGIC := '1';
    --! RAM output enable
    SIGNAL r_ram_oe_reg, r_ram_oe_next : STD_LOGIC := '1';
    --! RAM Write enable
    SIGNAL r_ram_we_reg, r_ram_we_next : STD_LOGIC := '1';

    --! Clock register enable and reset wire
    SIGNAL w_clock_counter_reset, w_clock_counter_enable : STD_LOGIC;
    --! address and data enable 
    SIGNAL w_input_address_enable : STD_LOGIC;
    SIGNAL w_ram_data_enable, w_input_data_enable : STD_LOGIC;

BEGIN

    ---------------------------------------------------------
    --                       outputs                       --
    --------------------------------------------------------- 
    o_data_valid <= r_output_data_valid_reg;
    o_ready <= r_ready_reg;
    o_ram_ce_n <= r_ram_ce_reg;
    o_ram_we_n <= r_ram_we_reg;
    o_ram_oe_n <= r_ram_oe_reg;
    o_ram_address <= r_address_reg;
    io_ram_data <= r_output_data_reg WHEN (NOT(r_ram_ce_reg) AND NOT(r_ram_we_reg) AND r_ram_oe_reg);
    o_data <= r_input_data_reg;
    ---------------------------------------------------------    
    --                   reg-state logic                   --
    ---------------------------------------------------------
    --! Clock counter with clock enable and reset
    reg_clock_counter : PROCESS (ALL)
    BEGIN
        IF w_clock_counter_reset = '1' THEN
            r_clock_count_reg <= (OTHERS => '0');
        ELSE
            IF w_clock_counter_enable = '1' AND rising_edge(i_clk) THEN
                r_clock_count_reg <= r_clock_count_next;
            END IF;
        END IF;
    END PROCESS;

    --! registers with or without clock enable and without reset
    registers_without_reset : PROCESS (ALL)
    BEGIN
        IF rising_edge(i_clk) THEN
            r_state_reg <= r_state_next;
            r_ram_we_reg <= r_ram_we_next;
            r_ram_ce_reg <= r_ram_ce_next;
            r_ram_oe_reg <= r_ram_oe_next;
            r_output_data_valid_reg <= r_output_data_valid_next;
            r_ready_reg <= r_ready_next;
            IF w_input_data_enable = '1' THEN
                r_output_data_reg <= r_output_data_next;
            END IF;
            IF w_ram_data_enable = '1' THEN
                r_input_data_reg <= io_ram_data;
            END IF;
            IF w_input_address_enable = '1' THEN
                r_address_reg <= i_address;
            END IF;
        END IF;
    END PROCESS;
    ---------------------------------------------------------
    --                  next-state logic                   --
    ---------------------------------------------------------

    --! Finite State Machine main precess
    uart_rx_fsm : PROCESS (ALL)
    BEGIN
        r_output_data_next <= i_data;      
        r_clock_count_next <= r_clock_count_reg + 1;
        r_ram_we_next <= r_ram_we_reg;
        r_ram_ce_next <= '1';
        r_ram_oe_next <= r_ram_oe_reg;
        r_output_data_valid_next <= r_output_data_valid_reg;
        r_ready_next <= '0';
        w_clock_counter_reset <= '1';
        w_clock_counter_enable <= '0';
        w_input_address_enable <= '0';
        w_input_data_enable <= '0';
        w_ram_data_enable <= '0';
        CASE(r_state_reg) IS
            WHEN FSM_IDLE => --! IDLE state
            r_ram_we_next <= '1';
            r_ram_oe_next <= '1';
            IF i_data_valid = '1' THEN --! Input data_valid pin is HIGH
                IF i_read_write = '1' THEN --! Detect READ or WRITE action
                    r_state_next <= FSM_WRITE;
                    w_input_data_enable <= '1'; --! set data read clock enable
                    r_ram_we_next <= '0';                    
                ELSE
                    r_state_next <= FSM_READ;
                    r_ram_ce_next <= '0';
                END IF;
                w_input_address_enable <= '1'; --! set address clock enable
            ELSE
                r_state_next <= FSM_IDLE;
                r_ready_next <= '1';
            END IF;
            WHEN FSM_READ => --! READ state
            r_ram_oe_next <= '0';
            IF r_clock_count_reg = g_CLKS_FOR_SETUP THEN --! after waiting setup time save output
                w_clock_counter_reset <= '1';
                w_clock_counter_enable <= '0';
                w_ram_data_enable <= '1'; --! clock enable to register RAM output data
                r_state_next <= FSM_CLEAN;
                r_output_data_valid_next <= '1';
            ELSE
                w_clock_counter_reset <= '0';
                w_clock_counter_enable <= '1';
                r_state_next <= FSM_READ;
            END IF;
            WHEN FSM_WRITE => --! WRITE state 
            r_ram_we_next <= '0';
            IF r_clock_count_reg = g_CLKS_FOR_SETUP THEN --! after waiting setup time save output
                w_clock_counter_reset <= '1';
                w_clock_counter_enable <= '0';
                w_ram_data_enable <= '1'; --! set data read clock enable
                r_state_next <= FSM_CLEAN;
            ELSE
                w_clock_counter_reset <= '0';
                w_clock_counter_enable <= '1';
                r_state_next <= FSM_WRITE;
            END IF;

            WHEN FSM_CLEAN => --! CLEAN state 
            r_ready_next <= '1';
            IF i_data_valid = '1' THEN --! input data are valid
                IF i_read_write = '1' THEN --! detecting read or write
                    r_state_next <= FSM_WRITE;
                    r_ram_we_next <= '0';
                    w_input_data_enable <= '1'; --! set data read clock enable
                ELSE
                    r_state_next <= FSM_READ;
                    r_ram_oe_next <= '0';
                END IF;
                w_input_address_enable <= '1'; --! set address clock enable
            else 
                r_state_next <= FSM_IDLE;
            END IF;

            WHEN OTHERS =>
            r_state_next <= FSM_IDLE;
        END CASE;
    END PROCESS;
END rtl;