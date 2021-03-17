# Entity: main
- **File:** main.vhd
- **Author:** Imants Pulkstenis
- **Version:** B
- **Date:** 17.03.2020
- **Copyright:** Copyright (c) 2021 Imants Pulkstenis
## Diagram
![Diagram](main.svg "Diagram")
## Description
*Project name:* Delay line 
 *Module name:* Delay line TOP entity
*Detailed description*:
 Tis is very long CARRY4 delay line for delay testing on oscilloscope.
 **Revision:**
 A - initial design  
 B - this version are for delay line testing
 C - 
## Generics and ports
### Table 1.1 Generics
| Generic name       | Type    | Value   | Description                                         |
| ------------------ | ------- | ------- | --------------------------------------------------- |
| g_DL_ELEMENT_COUNT | INTEGER | 150 * 4 |  delay element count in delay line. It must be n*4. |
### Table 1.2 Ports
| Port name     | Direction | Type      | Description                                                                                                                   |
| ------------- | --------- | --------- | ----------------------------------------------------------------------------------------------------------------------------- |
| i_clk         | in        | STD_LOGIC |  100MHz clock                                                                                                                 |
| o_clock       | out       | STD_LOGIC |  In FPGA (PLL) generated test signal that is connected to output pin without delay                                            |
| o_delay_clock | out       | STD_LOGIC |  In FPGA generated test signal that is driven through delay line and then to output pin for comparison with not delayed clock |
## Signals, constants and types
### Signals
| Name      | Type      | Description                         |
| --------- | --------- | ----------------------------------- |
| w_clk10   | STD_LOGIC |  10MHz clock for testing delay loop |
| w_clk100  | STD_LOGIC |  100MHz main clock                  |
| w_delay_0 | STD_LOGIC |  output of delay line No.0          |
| w_delay_1 | STD_LOGIC |  output of delay line No.1          |
## Instantiations
- **clk_wiz_instance**: work.clk_wiz_0

- **delay_line_inst_0**: work.delay_line
 delay line No.0
 

- **delay_line_inst_1**: work.delay_line
 delay line No.1
 

