/************************************************************************
Avalon-MM Interface for AES Decryption IP Core

Dong Kai Wang, Fall 2017

For use with ECE 385 Experiment 9
University of Illinois ECE Department

Register Map:

 0-3 : 4x 32bit AES Key
 4-7 : 4x 32bit AES Encrypted Message
 8-11: 4x 32bit AES Decrypted Message
   12: Not Used
	13: Not Used
   14: 32bit Start Register
   15: 32bit Done Register

************************************************************************/

module avalon_aes_interface (
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
	output logic [31:0] EXPORT_DATA		// Exported Conduit Signal to LEDs
	);


logic [31:0] Reg [0:15]; // 16 registers of the register file

logic AES_DONE = 0; // done flags

logic [127:0] AES_MSG_DEC;

initial begin
	for (int i=0;i<16;i++)
		Reg[i]=0;
end

always_ff @ (posedge CLK)
begin

	if(RESET) begin
		for(int i = 0; i< 16; i++)
			 Reg[i] <= 0;
	end

	else if(AVL_WRITE && AVL_CS)
	begin: SW_WRITE_TO_Reg
		if     (AVL_BYTE_EN == 4'b1111) Reg[AVL_ADDR] <= AVL_WRITEDATA;
		else if(AVL_BYTE_EN == 4'b1100) Reg[AVL_ADDR] <= AVL_WRITEDATA[ 31:16];
		else if(AVL_BYTE_EN == 4'b0011) Reg[AVL_ADDR] <= AVL_WRITEDATA[ 15:0];
		else if(AVL_BYTE_EN == 4'b1000) Reg[AVL_ADDR] <= AVL_WRITEDATA[ 31:24];
		else if(AVL_BYTE_EN == 4'b0100) Reg[AVL_ADDR] <= AVL_WRITEDATA[ 23:16];
		else if(AVL_BYTE_EN == 4'b0010) Reg[AVL_ADDR] <= AVL_WRITEDATA[ 15:8];
		else if(AVL_BYTE_EN == 4'b0001) Reg[AVL_ADDR] <= AVL_WRITEDATA[ 7:0];
	end

	// load state and done flag into 15
	{Reg[8],Reg[9],Reg[10],Reg[11]} <= AES_MSG_DEC;
	Reg[15] <= AES_DONE;
end

// instantiate AES decryption module
AES aes
	(.CLK, .RESET, .AES_START(Reg[14][0]), .AES_DONE, .AES_DEBUG(Reg[12][0]), .AES_STEP(Reg[13][0]),
	.AES_KEY({Reg[0],Reg[1],Reg[2],Reg[3]}),
	.AES_MSG_ENC({Reg[4],Reg[5],Reg[6],Reg[7]}),
	.AES_MSG_DEC);

assign AVL_READDATA = (AVL_CS && AVL_READ) ? Reg [AVL_ADDR]:16'b0; // set readdata as interested register
assign EXPORT_DATA = {Reg[0][31:16], Reg[3][15:0]}; // export aes key


endmodule
