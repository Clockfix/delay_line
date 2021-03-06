-----------------------------
--! Author: Imants Pulkstenis
--! Date: 05.03.2020
--! Project name: Delay line 
--! Module name: Delay line TOP entity
--!
--! Detailed module description:
--! 
--!
--! Revision:
--! A - initial design
--! B - 
--!
-----------------------------
--! ***Wavedrom*** example(not actual waveform):
--! { signal: [
--!   { name: "i_clk", wave: 'p.......' },
--!   { name: "o_led", wave: "x.==.=x.", data: ["0x01", "0x02", "0x03", "0x04"] },
--! ]}
-----------------------------

LIBRARY IEEE; --always use this library
USE IEEE.std_logic_unsigned.ALL; --extends the std_logic_arith library
USE IEEE.std_logic_arith.ALL; --basic arithmetic operations for representing integers in standard ways
USE IEEE.numeric_std.ALL; --use this library if arithmetic required
USE IEEE.std_logic_1164.ALL; --always use this library

ENTITY main IS
    GENERIC (
        g_DL_ELEMENT_COUNT : INTEGER := 100 * 4 --! delay element count in delay line. It must be n*4.
    );
    PORT (
        -- --Hardware on Basys 3 development board
        i_clk : IN STD_LOGIC; --! 100MHz clock
        i_event : IN STD_LOGIC; --! Event signal that is routed through delay line
        o_clock : OUT STD_LOGIC; --! In FPGA generated test signal that is connected with i_event - for testing
        -- btnC : IN std_logic; -- push button
        -- RsRx : IN std_logic; -- UART RX Data
        -- RsTx : OUT std_logic; -- UART TX Data
        o_led : OUT STD_LOGIC_VECTOR(15 DOWNTO 0) --! LEDs on Basys3 development board
        -- sw : IN std_logic_vector(3 DOWNTO 0)
    );
END main; --! Delay line TOP entity

ARCHITECTURE arch OF main IS

    COMPONENT clk_wiz_0
        PORT (
            -- Clock out ports
            o_clk10 : OUT STD_LOGIC;
            o_clk100 : OUT STD_LOGIC;
            -- Clock in ports
            i_clk1 : IN STD_LOGIC
        );
    END COMPONENT;

    SIGNAL w_thermometer : STD_LOGIC_VECTOR(g_DL_ELEMENT_COUNT - 1 DOWNTO 0); --! thermometer time code from primary delay line
    -- SIGNAL w_thermometer_sec : STD_LOGIC_VECTOR(g_DL_ELEMENT_COUNT - 1 DOWNTO 0); --! thermometer time code from secondary delay line
    SIGNAL w_hit_detected : STD_LOGIC; --! Hit detected signal
    SIGNAL w_counter : STD_LOGIC_VECTOR(15 DOWNTO 0); --! Output from hit counter
    SIGNAL w_clk10 : STD_LOGIC; --! 10MHz clock for testing delay loop
    SIGNAL w_clk100 : STD_LOGIC; --! 100MHz main clock 
    ATTRIBUTE keep : STRING;
    ATTRIBUTE keep OF w_thermometer : SIGNAL IS "true";
    ATTRIBUTE keep OF i_event : SIGNAL IS "true";
    ATTRIBUTE keep OF w_hit_detected : SIGNAL IS "true";
    ATTRIBUTE keep OF w_counter : SIGNAL IS "true";
    ATTRIBUTE keep OF w_clk10 : SIGNAL IS "true";
    ATTRIBUTE keep OF w_clk100 : SIGNAL IS "true";

BEGIN
    ---------------------------------------------------------    
    --             instantiate sub entities                --
    ---------------------------------------------------------

    --! PLL clock generator for test purposes
    clk_wiz_instance : clk_wiz_0
   port map ( 
  -- Clock out ports  
   o_clk10 => w_clk10, -- Clock out ports 
   o_clk100 => w_clk100,-- Clock out ports 
   -- Clock in ports
   i_clk1 => i_clk-- Clock in ports 
 );

    --! primary delay line
    --! 
    delay_line_inst_main : ENTITY work.delay_line
        GENERIC MAP(
            g_DL_ELEMENT_COUNT => g_DL_ELEMENT_COUNT,
            g_LOCATION => "SLICE_X0Y0"
        )
        PORT MAP(
            i_clk => w_clk100,
            TriggerIn => i_event,
            DffOut => w_thermometer, -- thermometer time code
            D => "0000", -- DI for CARRY4 block
            S => "1111"--, -- S for CARRY4 block
            -- LoopOut =>  ,
            -- nReset =>   
        );

    -- --! secondary delay line
    -- --! 
    -- delay_line_inst_sec : ENTITY work.delay_line
    --     GENERIC MAP(
    --         g_DL_ELEMENT_COUNT => g_DL_ELEMENT_COUNT,
    --         g_LOCATION => "SLICE_X1Y0"
    --     )
    --     PORT MAP(
    --         i_clk => i_clk,
    --         TriggerIn => i_event,
    --         DffOut => w_thermometer_sec, -- thermometer time code
    --         D => "0000", -- DI for CARRY4 block
    --         S => "1111"--, -- S for CARRY4 block
    --         -- LoopOut =>  ,
    --         -- nReset =>   
    --     );

    --! Hit detector entity
    --!
    hit_detector_inst : ENTITY work.hit_detector
        PORT MAP(
            i_clk => w_clk100, --! Main clock
            i_first_delay => w_thermometer(0), --!  Trigger form first element of delay line
            i_last_delay => w_thermometer(g_DL_ELEMENT_COUNT - 1), --!  Trigger form first element of delay line
            i_enable => '1', --! Enable hit detector logic
            o_hit_detected => w_hit_detected--! HIGH when hit is detected
        );

    --! Hit counter entity
    counter_inst : ENTITY work.counter
        PORT MAP(
            i_clk => w_clk100,
            i_hit_detected => w_hit_detected,
            o_counter => w_counter
        );
    ---------------------------------------------------------    
    --                   reg-state logic                   --
    ---------------------------------------------------------

    ---------------------------------------------------------
    --                  next-state logic                   --
    ---------------------------------------------------------

    ---------------------------------------------------------
    --                       outputs                       --
    --------------------------------------------------------- 

    --! This process controls LEDs on the board 
    -- led_control : PROCESS (w_thermometer, w_thermometer_sec)
    -- BEGIN
    --     o_led(15 DOWNTO 0) <= (OTHERS => '0'); -- set all LEDs in OFF state
    --     -- define LED output
    --     o_led(15) <= w_thermometer(g_dl_element_count - 1);
    --     o_led(14) <= w_thermometer_sec(g_dl_element_count - 1);
    -- END PROCESS;
    o_led <= w_counter;
    o_clock <= w_clk10;
END arch;