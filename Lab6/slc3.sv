//------------------------------------------------------------------------------
// Company: 		 UIUC ECE Dept.
// Engineer:		 Stephen Kempf
//
// Create Date:    
// Design Name:    ECE 385 Lab 6 Given Code - SLC-3 top-level (External SRAM)
// Module Name:    SLC3
//
// Comments:
//    Revised 03-22-2007
//    Spring 2007 Distribution
//    Revised 07-26-2013
//    Spring 2015 Distribution
//    Revised 09-22-2015 
//    Revised 04-25-2017 
//    Fall 2017 Distribution
//
//------------------------------------------------------------------------------

// Top level for Lab 6 with physical SRAM.
// For simulation with test_memory, you need to add another top-level module which
// instantiates slc3 and test_memory, and write another testbench which instantiate
// that new top-level module.
module slc3(
	input logic [15:0] S,
	input logic Clk, Reset, Run, Continue,
	output logic [11:0] LED,
	output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7,
	output logic CE, UB, LB, OE, WE,
	output logic [19:0] ADDR,
	inout wire [15:0] Data //tristate buffers need to be of type wire
);

// Declaration of push button synchronized active high signals
logic Reset_SH, Continue_SH, Run_SH;
// Synchronized Switches
logic[15:0] S_S;
// Unsynchronized Internal OE and WE
logic OE_Us, WE_US;

// Internal connections
logic BEN;
logic LD_MAR, LD_MDR, LD_IR, LD_BEN, LD_CC, LD_REG, LD_PC, LD_LED;
logic GatePC, GateMDR, GateALU, GateMARMUX;
logic [1:0] PCMUX, ADDR2MUX, ALUK;
logic DRMUX, SR1MUX, SR2MUX, ADDR1MUX;
logic MIO_EN;

// Mem2IO connections
logic [15:0] MDR_In; // connects to MDRMUX, data coming from mem2io
logic [15:0] Data_from_SRAM, Data_to_SRAM;

// Register Outputs
logic [15:0] MAR, MDR, IR, PC;

// Mux outputs
logic [15:0] MDR_mux ,PC_mux;

// ADDR MUXES
logic[15:0] ADDR1MUX_out, ADDR2MUX_out, MARMUX;
assign MARMUX = ADDR1MUX_out + ADDR2MUX_out;

// REGFILE and Muxes
logic[15:0] SR1_out, SR2_out, SR2_out_postmux;
logic[2:0] SR1_addr, SR2_addr, DR_addr;
assign SR2_addr = IR[2:0];

// ALU output
logic [15:0] ALU;

// Bus
logic [15:0] Bus;

// Signals being displayed on hex display
logic [3:0][3:0] hex_4;

// For week 1, hexdrivers will display IR
//HexDriver hex_driver3 (IR[15:12], HEX3);
//HexDriver hex_driver2 (IR[11:8], HEX2);
//HexDriver hex_driver1 (IR[7:4], HEX1);
//HexDriver hex_driver0 (IR[3:0], HEX0);
// For week 2, hexdrivers will be mounted to Mem2IO
 HexDriver hex_driver3 (hex_4[3][3:0], HEX3);
 HexDriver hex_driver2 (hex_4[2][3:0], HEX2);
 HexDriver hex_driver1 (hex_4[1][3:0], HEX1);
 HexDriver hex_driver0 (hex_4[0][3:0], HEX0);

// The other hex display will show PC for both weeks.
HexDriver hex_driver7 (PC[15:12], HEX7);
HexDriver hex_driver6 (PC[11:8], HEX6);
HexDriver hex_driver5 (PC[7:4], HEX5);
HexDriver hex_driver4 (PC[3:0], HEX4);

// Connect MAR to ADDR, which is also connected as an input into MEM2IO.
// MEM2IO will determine what gets put onto Data_CPU (which serves as a potential
// input into MDR)
assign ADDR = { 4'b00, MAR }; //Note, our external SRAM chip is 1Mx16, but address space is only 64Kx16
assign MIO_EN = ~OE;

// You need to make your own datapath module and connect everything to the datapath
// Be careful about whether Reset is active high or low
data_path d0 (.Bus(Bus), .PC(PC), .MARMUX, .ALU, .MDR, .GatePC, .GateMARMUX, .GateALU, .GateMDR);

// Our SRAM and I/O controller
Mem2IO memory_subsystem(
    .*, .Reset(Reset_SH), .ADDR(ADDR), .Switches(S_S),
    .HEX0(hex_4[0][3:0]), .HEX1(hex_4[1][3:0]), .HEX2(hex_4[2][3:0]), .HEX3(hex_4[3][3:0]),
    .Data_from_CPU(MDR), .Data_to_CPU(MDR_In),
    .Data_from_SRAM(Data_from_SRAM), .Data_to_SRAM(Data_to_SRAM)
);

// The tri-state buffer serves as the interface between Mem2IO and SRAM
tristate #(.N(16)) tr0(
    .Clk(Clk), .tristate_output_enable(~WE), .Data_write(Data_to_SRAM), .Data_read(Data_from_SRAM), .Data(Data)
);

// State machine and control signals
ISDU state_controller(
    .*, .Reset(Reset_SH), .Run(Run_SH), .Continue(Continue_SH),
    .Opcode(IR[15:12]), .IR_5(IR[5]), .IR_11(IR[11]),
    .Mem_CE(CE), .Mem_UB(UB), .Mem_LB(LB), .Mem_OE(OE_US), .Mem_WE(WE_US)
);
// TEST MEMORY // REMOVE WHEN RUNNING ON DE2 board
// test_memory tm(.Clk, .Reset(Reset_SH), .I_O(Data), .A(ADDR), .CE, .UB, .LB, .OE, .WE);

// MY STUFF from this point on------
// PC IR MAR MDR Registers
reg_16 PC_reg(.Clk, .Reset(Reset_SH), .Load(LD_PC), .D_In(PC_mux), .D_Out(PC));
reg_16 IR_reg(.Clk, .Reset(Reset_SH), .Load(LD_IR), .D_In(Bus), .D_Out(IR));
reg_16 MAR_reg(.Clk, .Reset(Reset_SH), .Load(LD_MAR), .D_In(Bus), .D_Out(MAR));
reg_16 MDR_reg(.Clk, .Reset(Reset_SH), .Load(LD_MDR), .D_In(MDR_mux), .D_Out(MDR));

// PCMUX MDRMUX
four_one_mux PCMUX_mux(.A(PC+1), .B(MARMUX), .C(Bus),      .D(16'hxxxx), .S(PCMUX), .Y(PC_mux)); // 00 choose pc+1, 01 choose from marmux, 10 choose from Bus
four_one_mux MDRMUX_mux(.A(Bus), .B(MDR_In),   .C(16'hxxxx), .D(16'hxxxx), .S({1'b0, MIO_EN}), .Y(MDR_mux)); // when MIO_EN is 1, should load from memory itself, when 0, set to bus

// Addr Mux
four_one_mux ADDR1_MUX_mux(.A(PC),    .B(SR1_out),     .C(16'hxxxx),.D(16'hxxxx), .S({1'b0, ADDR1MUX}), .Y(ADDR1MUX_out)); // 0 chooses pc, 1 chooses SR1
four_one_mux ADDR2_MUX_mux(.A(16'b0), .B(16'(signed'(IR[5:0]))), .C(16'(signed'(IR[8:0]))), .D(16'(signed'(IR[10:0]))), .S(ADDR2MUX), .Y(ADDR2MUX_out)); // 00 choose 0, 01 choose off6, 10 choose off9, 11 choose off11

// Register and muxes
reg_file REGFILE(.Clk, .Reset(Reset_SH), .In(Bus), .LD_REG, .DR_addr, .SR1_addr, .SR2_addr, .SR1_out, .SR2_out);
two_one_mux DR_ADDR_MUX  (.A(IR[11:9]), .B(3'b111), .S(DRMUX),  .Y(DR_addr)); // 0 chooses IR[11:9], 1 choose SR7 automatically. 
two_one_mux SR1_ADDR_MUX (.A(IR[8:6]),  .B(IR[11:9]), .S(SR1MUX), .Y(SR1_addr)); // SR1MUX of 0 will select lower IR, such in ADD, AND, NOT. SR1 1 will only be for STR op
four_one_mux SR2_OUT_MUX(.A(SR2_out), .B(16'(signed'(IR[4:0]))), .C(16'hxxxx), .D(16'hxxxx), .S({1'b0, SR2MUX}), .Y(SR2_out_postmux)); // choose signext of imm5 if SR2MUX is 1, choose sr2 if not

// ALU
ALU alu_inst(.A(SR1_out), .B(SR2_out_postmux), .ALUK, .ALU_out(ALU)); // add if 00, and if 01, not if 10, pass of 11

// Condition Calculator, NZP in this module
condition_calc CC(.Clk, .Reset(Reset_SH), .IR, .Bus, .LD_BEN, .LD_CC, .BEN);

// LED assignment for pause instruction
LED_controller LED_cont(.Clk, .IR, .LD_LED, .LED);

// Synchronizers, will cause inputs/output to be delayed by 1 clock cycle
// Input
sync button_sync[2:0] (Clk, {~Reset, ~Continue, ~Run}, {Reset_SH, Continue_SH, Run_SH});
sync switches_sync[15:0] (Clk, S, S_S);
// Output OE and WE must be synced to prevent writing due to glitch
sync_r1 output_sync[1:0] (Clk, Reset_SH, {OE_US, WE_US}, {OE, WE});

endmodule
