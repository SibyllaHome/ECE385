/************************************************************************
Avalon-MM Interface for AES Decryption IP Core

Dong Kai Wang, Fall 2017

For use with ECE 385 Experiment 9
University of Illinois ECE Department

Register Map:

 0 : P1_keycode
 1 : P1_x
 2 : P1_y
 3 : P1_width
 4 : P1_height
 5 : P1_health
 6 : P1_animation
 7 - 13 : P2_"

************************************************************************/

module avalon_game_interface (
	// Avalon Clock Input
	input logic CLK,

	// Avalon Reset Input
	input logic RESET,

	// Avalon-MM Slave Signals
	input  logic AVL_READ,					// Avalon-MM Read
	input  logic AVL_WRITE,					// Avalon-MM Write
	input  logic AVL_CS,						// Avalon-MM Chip Select
	input  logic [3:0] AVL_BYTE_EN,		// Avalon-MM Byte Enable
	input  logic [3:0] AVL_ADDR,			// Avalon-MM Address
	input  logic [31:0] AVL_WRITEDATA,	// Avalon-MM Write Data
	output logic [31:0] AVL_READDATA,	// Avalon-MM Read Data

	// Exported Conduit
	input logic VGA_VS,
	input logic [3:0] P1_Keycode, P2_Keycode,
	output logic [9:0] p1_x, p1_y, p1_width, p1_height, p1_health, p1_animation,
	output logic [9:0] p2_x, p2_y, p2_width, p2_height, p2_health, p2_animation
	);


logic [31:0] AVL_Reg [0:15]; // 16 registers of the register file
logic [31:0] Graphics_Reg [0:15]; // save a copy of avl_reg for each frame

always_ff @ (posedge CLK)
begin
	if(RESET) begin
		for(int i = 0; i< 16; i++)
			 AVL_Reg[i] <= 0;
	end

	else if(AVL_WRITE && AVL_CS)
	begin: SW_WRITE_TO_Reg
		if     (AVL_BYTE_EN == 4'b1111) AVL_Reg[AVL_ADDR] <= AVL_WRITEDATA;
		else if(AVL_BYTE_EN == 4'b1100) AVL_Reg[AVL_ADDR] <= AVL_WRITEDATA[ 31:16];
		else if(AVL_BYTE_EN == 4'b0011) AVL_Reg[AVL_ADDR] <= AVL_WRITEDATA[ 15:0];
		else if(AVL_BYTE_EN == 4'b1000) AVL_Reg[AVL_ADDR] <= AVL_WRITEDATA[ 31:24];
		else if(AVL_BYTE_EN == 4'b0100) AVL_Reg[AVL_ADDR] <= AVL_WRITEDATA[ 23:16];
		else if(AVL_BYTE_EN == 4'b0010) AVL_Reg[AVL_ADDR] <= AVL_WRITEDATA[ 15:8];
		else if(AVL_BYTE_EN == 4'b0001) AVL_Reg[AVL_ADDR] <= AVL_WRITEDATA[ 7:0];
	end
	// store keycode on every cycle
	AVL_Reg[0] <= P1_Keycode;
	AVL_Reg[7] <= P2_Keycode;
end

always_ff @ (negedge VGA_VS) 
begin
	for (int i = 0; i< 16; i++) // save copy
		Graphics_Reg[i] <= AVL_Reg[i];
end

assign AVL_READDATA = (AVL_CS && AVL_READ) ? AVL_Reg [AVL_ADDR] : 16'b0; // set readdata as interested register

// Assign export conduit
assign p1_x = Graphics_Reg[1][9:0];
assign p1_y = Graphics_Reg[2][9:0];
assign p1_width = Graphics_Reg[3][9:0];
assign p1_height = Graphics_Reg[4][9:0];
assign p1_health = Graphics_Reg[5][9:0];
assign p1_animation = Graphics_Reg[6][9:0];

assign p2_x = Graphics_Reg[8][9:0];
assign p2_y = Graphics_Reg[9][9:0];
assign p2_width = Graphics_Reg[10][9:0];
assign p2_height = Graphics_Reg[11][9:0];
assign p2_health = Graphics_Reg[12][9:0];
assign p2_animation = Graphics_Reg[13][9:0];

endmodule
