&nbsp;&nbsp;

# Entity: delay_line
## Diagram
![Diagram](delay_line.svg "Diagram")
## Description
## Generics and ports
### Table 1.1 Generics
| Generic name       | Type    | Value        | Description |
| ------------------ | ------- | ------------ | ----------- |
| g_DL_ELEMENT_COUNT | INTEGER | 16           |             |
| g_LOCATION         | STRING  | "SLICE_X1Y1" |             |
### Table 1.2 Ports
| Port name | Direction | Type                                              | Description |
| --------- | --------- | ------------------------------------------------- | ----------- |
| i_clk     | in        | STD_LOGIC                                         |             |
| TriggerIn | in        | STD_LOGIC                                         |             |
| DffOut    | out       | STD_LOGIC_VECTOR(g_DL_ELEMENT_COUNT - 1 DOWNTO 0) |             |
| D         | in        | STD_LOGIC_VECTOR(3 DOWNTO 0)                      |             |
| S         | in        | STD_LOGIC_VECTOR(3 DOWNTO 0)                      |             |
| LoopOut   | out       | STD_LOGIC                                         |             |
## Signals, constants and types
### Signals
| Name | Type                                              | Description |
| ---- | ------------------------------------------------- | ----------- |
| CO   | STD_LOGIC_VECTOR(g_DL_ELEMENT_COUNT - 1 DOWNTO 0) |             |
## Instantiations
- **CARRY4_first**: CARRY4

- **CARRY4_last**: CARRY4

