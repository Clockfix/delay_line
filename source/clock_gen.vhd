-----------------------------
--! @author Imants Pulkstenis 
--! @date 05.05.2021 
--! @file clock_gen.vhd
--! @version B
--! @copyright Copyright (c) 2021 Imants Pulkstenis
--! 
--! @brief *Project name:* Delay line 
--! *Module name:* Clock generator entity containing PLL/MMCM and other clock controls
--! 
--! @details *Detailed description*:
--! (no description)
--! **Revision:**
--! A - initial design  
--! B - entity form GUI clock wizard changed to MMCME2_BASE Primitive: Base Mixed Mode Clock Manager. 
--!     The MMCME2 is a mixed signal block designed to support frequency synthesis, clock network deskew, and jitter
--!     reduction. The clock outputs can each have an individual divide, phase shift and duty cycle based on the same
--!     TVCO frequency. Additionally, the MMCME2 supports dynamic phase shifting and fractional divides.
--! C - 

LIBRARY IEEE; --always use this library
USE IEEE.numeric_std.ALL; --use this library if arithmetic required
USE IEEE.std_logic_1164.ALL; --always use this library
LIBRARY UNISIM; -- Xilinx HDL Libraries
USE UNISIM.vcomponents.ALL; -- Xilinx HDL Libraries

ENTITY clock_gen IS
    PORT (
        i_clk : IN STD_LOGIC; --! Main clock input. For Basys3 board it is 100MHz
        o_clock100 : OUT STD_LOGIC; --! In FPGA (PLL) generated clock
        o_locked : OUT STD_LOGIC; --! Clock is locked
        o_clock10 : OUT STD_LOGIC --! 10MHz clock output
    );
END clock_gen; --! Delay line TOP entity

ARCHITECTURE rtl OF clock_gen IS

    SIGNAL w_clk100 : STD_LOGIC; --! 100MHz main clock  
    SIGNAL w_CLKOUT0 : STD_LOGIC; --! 1-bit output: CLKOUT0
    SIGNAL w_CLKOUT0B : STD_LOGIC; --! 1-bit output: Inverted CLKOUT0
    SIGNAL w_CLKOUT1 : STD_LOGIC; --! 1-bit output: CLKOUT1
    SIGNAL w_CLKOUT1B : STD_LOGIC; --! 1-bit output: Inverted CLKOUT1
    SIGNAL w_CLKOUT2 : STD_LOGIC; --! 1-bit output: CLKOUT2
    SIGNAL w_CLKOUT2B : STD_LOGIC; --! 1-bit output: Inverted CLKOUT2
    SIGNAL w_CLKOUT3 : STD_LOGIC; --! 1-bit output: CLKOUT3
    SIGNAL w_CLKOUT3B : STD_LOGIC; --! 1-bit output: Inverted CLKOUT3
    SIGNAL w_CLKOUT4 : STD_LOGIC; --! 1-bit output: CLKOUT4
    SIGNAL w_CLKOUT5 : STD_LOGIC; --! 1-bit output: CLKOUT5
    SIGNAL w_CLKOUT6 : STD_LOGIC; --! 1-bit output: CLKOUT6

    SIGNAL w_CLKFBOUT : STD_LOGIC; --! 1-bit output: Feedback clock
    SIGNAL w_CLKFBOUTB : STD_LOGIC; --! 1-bit output: Inverted CLKFBOUT
    SIGNAL w_LOCKED : STD_LOGIC; --! 1-bit output: LOCK
    SIGNAL w_CLKIN1 : STD_LOGIC; --! 1-bit input: Clock
    SIGNAL w_PWRDWN : STD_LOGIC; --! 1-bit input: Power-down
    SIGNAL w_RST : STD_LOGIC; --! 1-bit input: Reset
    --! 1-bit input: Feedback clock
    SIGNAL w_CLKFBIN : STD_LOGIC; 

BEGIN

    ---------------------------------------------------------
    --                       outputs                       --
    --------------------------------------------------------- 

    o_locked <= w_LOCKED;

    --! BUFGCE: Global Clock Buffer with Clock Enable
    --! 7 Series
    --! Xilinx HDL Libraries Guide, version 14.1
    Global_Clock_Buffer_with_Clock_Enable_clk100 : BUFGCE
    GENERIC MAP(
        SIM_DEVICE => "7SERIES" --! To avoid WARNING: [Netlist 29-345] The value of SIM_DEVICE on instance
    )
    PORT MAP(
        O => o_clock100, --! 1-bit output: Clock output
        CE => w_LOCKED, --! 1-bit input: Clock enable input for I0
        I => w_CLKOUT0 --! 1-bit input: Primary clock
    ); -- End of BUFGCE_inst instantiation


    --! BUFGCE: Global Clock Buffer with Clock Enable
    --! 7 Series
    --! Xilinx HDL Libraries Guide, version 14.1
    Global_Clock_Buffer_with_Clock_Enable_clk10 : BUFGCE
    GENERIC MAP(
        SIM_DEVICE => "7SERIES" --! To avoid WARNING: [Netlist 29-345] The value of SIM_DEVICE on instance
    )
    PORT MAP(
        O => o_clock10, --! 1-bit output: Clock output
        CE => w_LOCKED, --! 1-bit input: Clock enable input for I0
        I => w_CLKOUT1 --! 1-bit input: Primary clock
    ); -- End of BUFGCE_inst instantiation

    ---------------------------------------------------------    
    --             instantiate sub entities                --
    ---------------------------------------------------------

    --! IBUF: Single-ended Input Buffer
    --!    7 Series
    --! Xilinx HDL Libraries Guide, version 14.7
    input_clock_buffer : IBUF
    GENERIC MAP(
        IBUF_LOW_PWR => TRUE, -- Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards
        IOSTANDARD => "DEFAULT")
    PORT MAP(
        O => w_CLKIN1, -- Buffer output
        I => i_clk -- Buffer input (connect directly to top-level port)
    ); -- End of IBUF_inst instantiation

    --! MMCME2_BASE: Base Mixed Mode Clock Manager
    --! 7 Series
    --! Xilinx HDL Libraries Guide, version 14.7
    Base_Mixed_Mode_Clock_Manager : MMCME2_BASE
    GENERIC MAP(
        BANDWIDTH => "OPTIMIZED", -- Jitter programming (OPTIMIZED, HIGH, LOW)
        CLKFBOUT_MULT_F => 62.5, -- Multiply value for all CLKOUT (2.000-64.000).
        CLKFBOUT_PHASE => 0.0, -- Phase offset in degrees of CLKFB (-360.000-360.000).
        CLKIN1_PERIOD => 83.333, -- 12MHz input clock on Cmod 7 board
        -- Input clock period in ns to ps resolution (i.e. 33.333 is 30 MHz).
        -- CLKOUT0_DIVIDE - CLKOUT6_DIVIDE: Divide amount for each CLKOUT (1-128)
        CLKOUT1_DIVIDE => 75,
        CLKOUT2_DIVIDE => 1,
        CLKOUT3_DIVIDE => 1,
        CLKOUT4_DIVIDE => 1,
        CLKOUT5_DIVIDE => 1,
        CLKOUT6_DIVIDE => 1,
        CLKOUT0_DIVIDE_F => 7.50, -- Divide amount for CLKOUT0 (1.000-128.000).
        -- CLKOUT0_DUTY_CYCLE - CLKOUT6_DUTY_CYCLE: Duty cycle for each CLKOUT (0.01-0.99).
        CLKOUT0_DUTY_CYCLE => 0.5,
        CLKOUT1_DUTY_CYCLE => 0.5,
        CLKOUT2_DUTY_CYCLE => 0.5,
        CLKOUT3_DUTY_CYCLE => 0.5,
        CLKOUT4_DUTY_CYCLE => 0.5,
        CLKOUT5_DUTY_CYCLE => 0.5,
        CLKOUT6_DUTY_CYCLE => 0.5,
        -- CLKOUT0_PHASE - CLKOUT6_PHASE: Phase offset for each CLKOUT (-360.000-360.000).
        CLKOUT0_PHASE => 0.0,
        CLKOUT1_PHASE => 0.0,
        CLKOUT2_PHASE => 0.0,
        CLKOUT3_PHASE => 0.0,
        CLKOUT4_PHASE => 0.0,
        CLKOUT5_PHASE => 0.0,
        CLKOUT6_PHASE => 0.0,
        CLKOUT4_CASCADE => FALSE, -- Cascade CLKOUT4 counter with CLKOUT6 (FALSE, TRUE)
        DIVCLK_DIVIDE => 1, -- Master division value (1-106)
        REF_JITTER1 => 0.0, -- Reference input jitter in UI (0.000-0.999).
        STARTUP_WAIT => FALSE -- Delays DONE until MMCM is locked (FALSE, TRUE)
    )
    PORT MAP(
        -- Clock Outputs: 1-bit (each) output: User configurable clock outputs
        CLKOUT0 => w_CLKOUT0, --! 1-bit output: CLKOUT0
        CLKOUT0B => w_CLKOUT0B, --! 1-bit output: Inverted CLKOUT0
        CLKOUT1 => w_CLKOUT1, --! 1-bit output: CLKOUT1
        CLKOUT1B => w_CLKOUT1B, --! 1-bit output: Inverted CLKOUT1
        CLKOUT2 => w_CLKOUT2, --! 1-bit output: CLKOUT2
        CLKOUT2B => w_CLKOUT2B, --! 1-bit output: Inverted CLKOUT2
        CLKOUT3 => w_CLKOUT3, --! 1-bit output: CLKOUT3
        CLKOUT3B => w_CLKOUT3B, --! 1-bit output: Inverted CLKOUT3
        CLKOUT4 => w_CLKOUT4, --! 1-bit output: CLKOUT4
        CLKOUT5 => w_CLKOUT5, --! 1-bit output: CLKOUT5
        CLKOUT6 => w_CLKOUT6, --! 1-bit output: CLKOUT6
        -- Feedback Clocks: 1-bit (each) output: Clock feedback ports
        CLKFBOUT => w_CLKFBOUT, --! 1-bit output: Feedback clock
        CLKFBOUTB => w_CLKFBOUTB, --! 1-bit output: Inverted CLKFBOUT
        -- Status Ports: 1-bit (each) output: MMCM status ports
        LOCKED => w_LOCKED, --! 1-bit output: LOCK
        -- Clock Inputs: 1-bit (each) input: Clock input
        CLKIN1 => w_CLKIN1, --! 1-bit input: Clock
        -- Control Ports: 1-bit (each) input: MMCM control ports
        PWRDWN => w_PWRDWN, --! 1-bit input: Power-down
        RST => w_RST, --! 1-bit input: Reset
        -- Feedback Clocks: 1-bit (each) input: Clock feedback ports
        CLKFBIN => w_CLKFBIN --! 1-bit input: Feedback clock
    ); -- End of MMCME2_BASE_inst instantiation


    --! BUFG: Global Clock Simple Buffer
    --!    7 Series
    --! Xilinx HDL Libraries Guide, version 14.7
    feedback_buffer : BUFG
    PORT MAP(
        O => w_CLKFBIN, --! 1-bit output: Clock output
        I => w_CLKFBOUT --! 1-bit input: Clock input
    ); -- End of BUFG_inst instantiation

END rtl;