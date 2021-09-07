-----------------------------
--! @author Imants Pulkstenis 
--! @date 24.08.2021 
--! @file cmod_a7_test.vhd
--! @version A
--! @copyright Copyright (c) 2021 Imants Pulkstenis
--! 
--! @brief *Project name:* Delay line 
--! *Module name:* Cmod A7 board test top entity
--! 
--! @details *Detailed description*:
--! (no description)
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

ENTITY cmod_a7_test IS
    PORT (
        -- -- Hardware on Cmod A7 development board
        i_sysclk : IN STD_LOGIC; --! 12MHz input clock
        o_led : OUT STD_LOGIC_VECTOR (1 DOWNTO 0); --! Two output led's
        i_btn : IN STD_LOGIC_VECTOR (1 DOWNTO 0); --! Two input buttons
        o_led0_b : OUT STD_LOGIC; --! blue
        o_led0_g : OUT STD_LOGIC; --! green
        o_led0_r : OUT STD_LOGIC; --! red
        o_pio26 : OUT STD_LOGIC; --! test pin
        o_pio27 : OUT STD_LOGIC; --! test pin
        o_pio28 : OUT STD_LOGIC; --! test pin
        o_uart_rxd_out : OUT STD_LOGIC; --! UART RX
        i_uart_txd_in : IN STD_LOGIC --! UART TX
    );
END cmod_a7_test; --! Cmod A7 test TOP entity

ARCHITECTURE rtl OF cmod_a7_test IS

    SIGNAL w_clk100 : STD_LOGIC; --! 100MHz main clock 
    SIGNAL w_clk10 : STD_LOGIC; --! 10MHz slow clock 
    SIGNAL r_counter_reg, r_counter_next : UNSIGNED(31 DOWNTO 0) := (OTHERS => '0'); --! Counter that controls LED 
    --! locked output from PLL/MMCM 
    SIGNAL w_locked : STD_LOGIC; --! locked output from PLL/MMCM 
    SIGNAL w_rx_data_valid : STD_LOGIC; --! received data byte from UART and rx_byte data are valid
    --! Received byte
    SIGNAL w_rx_byte : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL w_tx_active : STD_LOGIC;

    -- ATTRIBUTE keep : STRING;
    -- ATTRIBUTE keep OF w_clk100 : SIGNAL IS "true";

BEGIN

    ---------------------------------------------------------
    --                       outputs                       --
    --------------------------------------------------------- 

    o_led(0) <= w_locked;
    o_led(1) <= r_counter_reg(15);
    o_led0_b <= '0' WHEN w_rx_byte = x"62" ELSE
        '1';
    o_led0_g <= '0' WHEN w_rx_byte = x"67" ELSE
        '1';
    o_led0_r <= '0' WHEN w_rx_byte = x"72" ELSE
        '1';
    o_pio26 <= w_clk100;
    o_pio27 <= i_uart_txd_in;
    o_pio28 <= r_counter_reg(15);
    -- uart_rxd_out <= '1';

    ---------------------------------------------------------    
    --             instantiate sub entities                --
    ---------------------------------------------------------
    --!  Clock generator entity
    clock_gen_inst : ENTITY work.clock_gen
        PORT MAP(
            i_clk => i_sysclk, --! Main clock input. For Basys3 board it is 100MHz
            o_clock100 => w_clk100, --! In FPGA (PLL/ MMCM ) generated clock
            o_locked => w_locked, --! locked output from PLL/MMCM 
            o_clock10 => w_clk10 --! In FPGA (PLL/ MMCM ) generated clock
        );

    --! UART loopback entity
    uart_inst : ENTITY work.uart_loopback
        GENERIC MAP(
            g_CLKS_PER_BIT => 86 --! Clocks per one bit '''@115200''' baud and '''@100MHz''' clock
        )
        PORT MAP(
            i_clk => w_clk10, --! input clock
            i_rx_line => i_uart_txd_in, --! RX input line
            o_tx_line => o_uart_rxd_out, --! TX output line
            o_rx_byte => w_rx_byte, --! Outputs received byte
            i_tx_byte => w_rx_byte, --! Outputs received byte
            o_rx_data_valid => w_rx_data_valid, --! Data valid on output
            i_tx_dv => w_rx_data_valid AND (NOT w_tx_active), --! TX input data valid
            o_tx_Active => w_tx_active -- , --! active transmission
            -- o_tx_Done =>   --! Transmission done
        );
    ---------------------------------------------------------    
    --                   reg-state logic                   --
    ---------------------------------------------------------
    --!  Counter process
    reg_state_logic : PROCESS (ALL)
    BEGIN
        IF rising_edge(w_clk100) THEN
            r_counter_reg <= r_counter_next;
        END IF;
    END PROCESS;
    ---------------------------------------------------------
    --                  next-state logic                   --
    ---------------------------------------------------------
    r_counter_next <= r_counter_reg + 1;
END rtl;