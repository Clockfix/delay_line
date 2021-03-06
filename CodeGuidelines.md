# Code Guidelines for VHDL and Verilog 
©[https://www.nandland.com](https://www.nandland.com/articles/coding-style-recommendations-vhdl-verilog.html)
Below are the coding style rules that I have found to be most beneficial throughout my years as a Digital Designer. I recommend adopting all of these. Note that these are recommended for both VHDL and Verilog in order to keep consistency. There are three main benefits to adopting the coding style below. 
1.	High readability of code, code is easily understood 
2.	Improved thoughtfulness of code writing 
3.	Code is less error-prone

## Prefixes: 
 -   i_   Input signal 
 -   o_   Output signal 
 -   r_   Register signal (has registered logic) 
 -   w_   Wire signal (has no registered logic) 
 -   c_   Constant 
 -   g_   Generic (VHDL only)
 -   t_   User-Defined Type  

### i_ and o_ prefix:
This is the most important style you should adopt! Too many designers do not indicate if their signals are inputs or outputs from an entity/module. It can be very difficult and annoying to look through the code to determine the direction of a signal. Additionally, a signal that is named "data" and is output will be much harder to find in your code via a search than a signal that is named "o_data"—examples: i_address, o_data_valid.

### r_ and w_ prefix
This is the second most important style you need to use. Indicating if your signal is a register or a wire is hugely important to writing good code. Verilog is nice in that it forces you to declare your signal as a reg or a wire, but VHDL has no such requirement! Therefore this style is especially important for VHDL coders. All signals declared with r_ should have initial conditions. All signals declared with w_ should never appear to the left-hand side of an assignment operator in a sequential process (in VHDL) or a clocked always block (in Verilog). Examples: r_Row_Count, w_Pixel_Done.

### c_, g_, and t_, prefix
These are helpful indicators when coding. c_ indicates that you are referring to a constant in VHDL or a parameter in Verilog. g_ is used for all VHDL generics. t_ indicates that you are defining your own data type. I find these helpful. Examples: c_NUM_BYTES, t_MAIN_STATE_MACHINE. For state machines, I like using all capital letters... e.g. IDLE, DONE, CLEANUP. In the past, I've used s_ to indicate state but I've moved away from that. Preferences change. 

### A Note About Capitalization:
In this course, we capitalize all GENERICS, CONSTANTS, and TYPE data types.

Whether or not you want to capitalize your signal names is up to you. As you can see in the examples above, I capitalize all of my signals that are not inputs or outputs, except for the prefix. Should you prefer to name a signal r_Row_Count or r_row_count rather than r_ROW_COUNT, well that's up to you. I would recommend, though, that you stay consistent! VHDL is not case-sensitive, so r_ROW_COUNT is the same as r_Row_Count, but this is not true in Verilog. Verilog is case sensitive, so maintaining rules about capitalization is very important! You don't want to accidentally create two different signals when you meant to create just one signal, or you will have a very bad time.

### A Note About Initializing Signals:
There is a fairly widespread misconception that FPGAs need to have a reset signal into a register in order to set an initial condition. **This is not true, FPGA registers can have initial values**. All FPGAs can be initialized to zero or non-zero values. It's actually best-practice to *[reset as few Flip-Flops as possible](http://www.xilinx.com/support/documentation/white_papers/wp272.pdf)* in your design and to rely on initializing all Flip-Flops instead. The reason for this is that each reset line you add to a Flip-Flop takes routing resources and power and makes your design harder to meet timing.
The rule you should be following is this: All registers (as identified by r_ prefix) should always have an initial condition applied to them. No wires (as identified by w_ prefix) should EVER have an initial condition applied to them. When you simulate your design, all signals should be a nice happy **green** before the simulation even starts. If this is true, you will be much happier. 
The above guidelines are what I've adopted over many years of Digital Design. I do these things because I find them very beneficial to the quality and speed of my work.
