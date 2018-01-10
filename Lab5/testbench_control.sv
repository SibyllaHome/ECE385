module testbench_control();
timeunit 10ns; // Half clock cycle at 50 MHz
// This is the amount of time represented by #1
timeprecision 1ns;
// These signals are internal because the processor will be
// instantiated as a submodule in testbench.
logic Clk = 0;
logic Reset, Run, ClearA_LoadB, ClearA, LoadB, Shift, Add, Sub;
logic[7:0] S;
logic[7:0] Aval, Bval;
logic[6:0] AhexU, AhexL, BhexU, BhexL;
logic[15:0] product;
logic X;

assign product = {Aval,Bval};

// Instantiating the DUT
// Make sure the module and signal names match with those in your design
top_level_multiplier tlm(.*);
// Toggle the clock
// #1 means wait for a delay of 1 timeunit
always begin : CLOCK_GENERATION
#1 Clk = ~Clk;
end
initial begin: CLOCK_INITIALIZATION
 Clk = 0;
end
// Testing begins here
// The initial block is not synthesizable
// Everything happens sequentially inside an initial block
// as in a software program
initial begin: TEST_VECTORS
Reset = 1;
ClearA_LoadB = 1;
Run = 1;
S = 8'b11100000; // LoadB to -32, E0
#2 Reset = 0; // Toggle Rest
#2 Reset = 1; // Toggle Rest
#2 ClearA_LoadB = 0;
#2 ClearA_LoadB = 1;
#2 S = 8'b00000101; // S = 5
#2 Run = 0;
#2 Run = 1;
// Should get -160 FF60


#38 S = 8'b01111011; // LoadB to 123 7b
#2 ClearA_LoadB = 0;
#2 ClearA_LoadB = 1;
#2 S = 8'b11100001; // S = -31
#2 Run = 0;
#2 Run = 1;
// Should get -3813 F11b


#38 S = 8'b11100000; // LoadB to -32 E0
#2 ClearA_LoadB = 0;
#2 ClearA_LoadB = 1;
#2 S = 8'b11100001; // S = -31
#2 Run = 0;
#2 Run = 1;
// 992


#38 S = 8'h74; // LoadB to 123 E0
#2 ClearA_LoadB = 0;
#2 ClearA_LoadB = 1;
#2 S = 8'h74; // S = 5
#2 Run = 0;
#2 Run = 1;
// Should get 615
end
endmodule