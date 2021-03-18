# Entity: delay_line
- **File:** delay_line.vhd
- **Author:** Imants Pulkstenis
- **Version:** B
- **Date:** 17.03.2020
- **Copyright:** Copyright (c) 2021 Imants Pulkstenis
## Diagram
![Diagram](delay_line.svg "Diagram")
## Description
Project name: Delay line
 Module name: Delay line module 
Delay line module for Xilinx 7 series. Its length can be configurable from the top module.
 The Delay line consists of MUXes(CARRY4 primitives) and D flip Flops at the output.
 -------------------------------------------------------------
 ***CARRY4*** (description from *Xilinx 7 Series FPGA Libraries Guide for HDL Designs*)
 Primitive: Fast Carry Logic with Look Ahead
     **Introduction**
 This circuit design represents the fast carry logic for a slice. The carry chain consists of a series of four MUXes
 and four XORs that connect to the other logic (LUTs) in the slice via dedicated routes to form more complex
 functions. The fast carry logic is useful for building arithmetic functions like adders, counters, subtractors and
 add/subs, as well as such other logic functions as wide comparators, address decoders, and some logic gates
 (specifically, AND and OR).
    **Port Descriptions**
 ```
      |  Port  | Direction | Width |                  Function                  |
      | ------ | --------- | ----- | ------------------------------------------ |
      | O      | Output    | 4     | Carry chain XOR general data out           |
      | CO     | Output    | 4     | Carry-out of each stage of the carry chain |
      | DI     | Input     | 4     | Carry-MUX data input                       |
      | S      | Input     | 4     | Carry-MUX select line                      |
      | CYINIT | Input     | 1     | Carry-in initialization input              |
      | CI     | Input     | 1     | Carry cascade input                        |
 ```  
 -------------------------------------------------------------
 **Revision:**
 A - initial design
 B - Long delay line test without D-Flip-Flops
 C - 
 -----------------------------
## Generics and ports
### Table 1.1 Generics
| Generic name       | Type    | Value        | Description                                                                                                                                                                       |
| ------------------ | ------- | ------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| g_DL_ELEMENT_COUNT | INTEGER | 16           |  Count of delay elements in the module. Four delay elements are in one CARRY4 primitive. The minimal number of CARRY4 blocks are 2, e.i. minimal delay element count are 2*4=8.   |
| g_LOCATION         | STRING  | "SLICE_X1Y1" |  Location of the first CARRY4 block                                                                                                                                               |
### Table 1.2 Ports
| Port name | Direction | Type      | Description           |
| --------- | --------- | --------- | --------------------- |
| TriggerIn | in        | STD_LOGIC |  Input of delay line  |
| LoopOut   | out       | STD_LOGIC |  Output of delay line |
## Signals, constants and types
### Signals
| Name | Type                                              | Description                                                 |
| ---- | ------------------------------------------------- | ----------------------------------------------------------- |
| CO   | STD_LOGIC_VECTOR(g_DL_ELEMENT_COUNT - 1 DOWNTO 0) |  CO vector from Carry-out of each stage of the carry chain  |
## Instantiations
- **CARRY4_first**: CARRY4

- **CARRY4_last**: CARRY4
 CARRY4: Fast Carry Logic Component

