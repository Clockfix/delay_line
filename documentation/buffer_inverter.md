# Entity: buffer_inverter
- **File:** buffer_inverter.vhd
- **Author:** Imants Pulkstenis
- **Version:** A
- **Date:** 18.03.2020
- **Copyright:** Copyright (c) 2021 Imants Pulkstenis
## Diagram
![Diagram](buffer_inverter.svg "Diagram")
## Description
Project name: Delay line
 Module name: NOT gate implementation 
buffer/inverter are based on LUT1 primitive
 Primitive: 1-Bit Look-Up Table with General Output
 -------------------------------------------------------------
 **Revision:**
 A - initial design
 B - 
 C - 
 -----------------------------
 ***schematic*** representation:
 
![alt text](wavedrom_5nJo0.svg "title") 

 
![alt text](wavedrom_rE6z1.svg "title") 

 -----------------------------
## Generics and ports
### Table 1.1 Generics
| Generic name | Type                         | Value | Description                                                                                            |
| ------------ | ---------------------------- | ----- | ------------------------------------------------------------------------------------------------------ |
| g_INIT       | STD_LOGIC_VECTOR(1 DOWNTO 0) | "01"  |  Binary number assigned to the INIT attribute. Default value "01" that configures this LUT1 as buffer  |
### Table 1.2 Ports
| Port name | Direction | Type      | Description              |
| --------- | --------- | --------- | ------------------------ |
| i         | in        | STD_LOGIC |  buffer/inverter Input   |
| o         | out       | STD_LOGIC |  buffer/inverter Output  |
## Instantiations
- **LUT1_inst**: LUT1

