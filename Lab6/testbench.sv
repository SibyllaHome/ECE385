module testbench();
timeunit 10ns; // Half clock cycle at 50 MHz
// This is the amount of time represented by #1
timeprecision 1ns;
// These signals are internal because the processor will be
// instantiated as a submodule in testbench.
logic Clk = 0;
logic Reset, Run, Continue;
logic[15:0] S;
logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7;
logic CE, UB, LB, OE, WE;
logic [19:0] ADDR;
wire [15:0] Data;
logic[11:0] LED;

// Instantiating the cpu
slc3 cpu(.*);

// Assign breakout internal wires
logic[15:0] PC, IR, MDR, MAR;
logic N,Z,P,BEN;
assign IR = cpu.IR;
assign PC = cpu.PC;
assign MDR = cpu.MDR;
assign MAR = cpu.MAR;
assign N = cpu.CC.N;
assign Z = cpu.CC.Z;
assign P = cpu.CC.P;
assign BEN = cpu.BEN;

// Breakout Register File
logic[15:0] R0, R1, R2;
assign R0 = cpu.REGFILE.regs[0];
assign R1 = cpu.REGFILE.regs[1];
assign R2 = cpu.REGFILE.regs[2];

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
S = 16'd6;
Reset = 1;
Run = 1;
Continue = 1;
#2 Reset = 0; // Toggle Rest
#2 Reset = 1; // Toggle Rest
#2 Run = 0;
#2 Run = 1;

end
endmodule