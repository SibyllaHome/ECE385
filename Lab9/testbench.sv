module testbench();
timeunit 10ns; // Half clock cycle at 50 MHz
// This is the amount of time represented by #1
timeprecision 1ns;
// These signals are internal because the processor will be
// instantiated as a submodule in testbench.
logic CLK = 0;
logic RESET = 0;
logic AVL_READ;					// Avalon-MM Read
logic AVL_WRITE;					// Avalon-MM Write
logic AVL_CS;						// Avalon-MM Chip Select
logic [3:0] AVL_BYTE_EN;		// Avalon-MM Byte Enable
logic [3:0] AVL_ADDR;			// Avalon-MM Address
logic [31:0] AVL_WRITEDATA;	// Avalon-MM Write Data
logic [31:0] AVL_READDATA;	// Avalon-MM Read Data

logic [127:0] AES_MSG_ENC = 128'hdaec3055df058e1c39e814ea76f6747e;
logic [127:0] AES_MSG_DEC;
logic [127:0] AES_KEY = 128'h000102030405060708090a0b0c0d0e0f;

logic [31:0] EXPORT_DATA;

static int i = 0;

// Instantiating
avalon_aes_interface aes(.*);

// Toggle the clock
// #1 means wait for a delay of 1 timeunit
always begin : CLOCK_GENERATION
#1 CLK = ~CLK;
end
initial begin: CLOCK_INITIALIZATION
	CLK = 0;
end
// Testing begins here
// The initial block is not synthesizable
// Everything happens sequentially inside an initial block
// as in a software program
initial begin: TEST_VECTORS
AVL_CS = 1;
AVL_WRITE = 1;
AVL_READ = 0;
AVL_BYTE_EN = 4'b1111;

#20
// write enc
	AVL_ADDR = 4;
	AVL_WRITEDATA = AES_MSG_ENC[127:96];
#20 AVL_ADDR = 5;
	AVL_WRITEDATA = AES_MSG_ENC[95:64];
#20 AVL_ADDR = 6;
	AVL_WRITEDATA = AES_MSG_ENC[63:32];
#20 AVL_ADDR = 7;
	AVL_WRITEDATA = AES_MSG_ENC[31:0];
	
// write key 
#20 AVL_ADDR = 0;
	AVL_WRITEDATA = AES_KEY[127:96];
#20 AVL_ADDR = 1;
	AVL_WRITEDATA = AES_KEY[95:64];
#20 AVL_ADDR = 2;
	AVL_WRITEDATA = AES_KEY[63:32];
#20 AVL_ADDR = 3;
	AVL_WRITEDATA = AES_KEY[31:0];
	
#20 AVL_ADDR = 12; // set to debug mode
	AVL_WRITEDATA = 0;
	
#20 AVL_ADDR = 14;
	AVL_WRITEDATA = 1;

#20 AVL_WRITE = 0;
	AVL_CS = 0;
	
#20
AVL_CS = 1;
AVL_ADDR = 15;
AVL_READ = 1;

#20
while (AVL_READDATA == 0)
	begin
	#20 AVL_READ = 0;
		AVL_ADDR = 13; // do steps
		AVL_WRITEDATA = i;
		AVL_WRITE = 1;
		$display("step: %d", i);
		i++;
	#20 AVL_WRITE = 0; // read done flag again
		AVL_ADDR = 15;
		AVL_READ = 1;
	#20 if (AVL_READDATA == 1) break;
	end

//i = 0;
//#20
//AVL_READ = 0;
//AVL_ADDR = 13; // reset step
//AVL_WRITEDATA = i;
//AVL_WRITE = 1;	
//
//// test 2
//#20
//	AES_MSG_ENC = 128'h439d619920ce415661019634f59fcf63;
//	AES_KEY = 128'h3b280014beaac269d613a16bfdc2be03;
//	AVL_ADDR = 14;
//	AVL_WRITEDATA = 0;
//	AVL_WRITE = 1;
//#20
//// write enc
//	AVL_ADDR = 4;
//	AVL_WRITEDATA = AES_MSG_ENC[127:96];
//#20 AVL_ADDR = 5;
//	AVL_WRITEDATA = AES_MSG_ENC[95:64];
//#20 AVL_ADDR = 6;
//	AVL_WRITEDATA = AES_MSG_ENC[63:32];
//#20 AVL_ADDR = 7;
//	AVL_WRITEDATA = AES_MSG_ENC[31:0];
//	
//// write key 
//#20 AVL_ADDR = 0;
//	AVL_WRITEDATA = AES_KEY[127:96];
//#20 AVL_ADDR = 1;
//	AVL_WRITEDATA = AES_KEY[95:64];
//#20 AVL_ADDR = 2;
//	AVL_WRITEDATA = AES_KEY[63:32];
//#20 AVL_ADDR = 3;
//	AVL_WRITEDATA = AES_KEY[31:0];
//
//#2 AVL_ADDR = 12; // set to regular mode
//	AVL_WRITEDATA = 0;
//	
//#2 AVL_ADDR = 14;
//	AVL_WRITEDATA = 1;
//
//#2 AVL_WRITE = 0;
//	AVL_CS = 0;


end
endmodule