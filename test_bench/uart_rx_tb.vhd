LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY uart_rx_tb IS
END uart_rx_tb;

ARCHITECTURE behave OF uart_rx_tb IS


    COMPONENT uart_rx IS
        GENERIC (
            g_CLKS_PER_BIT : INTEGER := 115 -- Needs to be set correctly
        );
        PORT (
            i_clk : IN STD_LOGIC;
            i_rx_line : IN STD_LOGIC;
            o_rx_data_valid : OUT STD_LOGIC;
            o_rx_byte : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
        );
    END COMPONENT uart_rx;
    -- Test Bench uses a 10 MHz Clock
    -- Want to interface to 115200 baud UART
    -- 10000000 / 115200 = 87 Clocks Per Bit.
    CONSTANT c_CLKS_PER_BIT : INTEGER := 87;

    CONSTANT c_BIT_PERIOD : TIME := 8680 ns;

    SIGNAL r_CLOCK : STD_LOGIC := '0';

    SIGNAL w_RX_DV : STD_LOGIC;
    SIGNAL w_RX_BYTE : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL r_RX_SERIAL : STD_LOGIC := '1';
    -- Low-level byte-write
    PROCEDURE UART_WRITE_BYTE (
        i_data_in : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        SIGNAL o_serial : OUT STD_LOGIC) IS
    BEGIN

        -- Send Start Bit
        o_serial <= '0';
        WAIT FOR c_BIT_PERIOD;

        -- Send Data Byte
        FOR ii IN 0 TO 7 LOOP
            o_serial <= i_data_in(ii);
            WAIT FOR c_BIT_PERIOD;
        END LOOP; -- ii

        -- Send Stop Bit
        o_serial <= '1';
        WAIT FOR c_BIT_PERIOD;
    END UART_WRITE_BYTE;
BEGIN

    -- Instantiate UART Receiver
    UART_RX_INST : uart_rx
    GENERIC MAP(
        g_CLKS_PER_BIT => c_CLKS_PER_BIT
    )
    PORT MAP(
        i_clk => r_CLOCK,
        i_rx_line => r_RX_SERIAL,
        o_rx_data_valid => w_RX_DV,
        o_rx_byte => w_RX_BYTE
    );

    r_CLOCK <= NOT r_CLOCK AFTER 50 ns;

    PROCESS IS
    BEGIN

        -- Send a command to the UART
        WAIT UNTIL rising_edge(r_CLOCK);
            UART_WRITE_BYTE(X"ad", r_RX_SERIAL);
        WAIT UNTIL rising_edge(r_CLOCK);

        -- Check that the correct command was received
        IF w_RX_BYTE = X"ad" THEN
            REPORT "Test Passed - Correct Byte Received" SEVERITY note;
        ELSE
            REPORT "Test Failed - Incorrect Byte Received" SEVERITY note;
        END IF;

        ASSERT false REPORT "Tests Complete" SEVERITY failure;

    END PROCESS;

END behave;