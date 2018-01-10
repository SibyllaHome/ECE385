/************************************************************************
AES Decryption Core Logic

Dong Kai Wang, Fall 2017

For use with ECE 385 Experiment 9
University of Illinois ECE Department
************************************************************************/

module AES (
	input	 logic CLK,
	input  logic RESET,
	input  logic AES_START,
	input  logic AES_DEBUG,
	input  logic AES_STEP,
	output logic AES_DONE,
	input  logic [127:0] AES_KEY,
	input  logic [127:0] AES_MSG_ENC,
	output logic [127:0] AES_MSG_DEC
);

logic [1407:0] KeySchedule;
logic [127:0] State, Key, AddRoundKeyOut, InvShiftRowsOut, InvMixColumnsOut, InvSubByteOut;

logic [3:0] Round;
logic [1:0] Column;
logic SubByte_Read;
logic AddKey_En, ShiftRow_En, SubByte_En, MixColumn_En, Initialization_En, Load_En;

assign AES_MSG_DEC = State;

always_ff @ (posedge CLK) // set state at each cycle
begin
	if (Initialization_En) // initialize by storing own copy of state and key
	begin
		State <= AES_MSG_ENC;
		Key <= AES_KEY;
	end
	else if (AddKey_En & Load_En) // loading state register from combinational logic > mux. 
		State <= AddRoundKeyOut;
	else if (ShiftRow_En & Load_En)
		State <= InvShiftRowsOut;
	else if (SubByte_En & SubByte_Read & Load_En)
		State <= InvSubByteOut;
	else if (MixColumn_En & Load_En)
		State <= InvMixColumnsOut;
	else
		State <= State;
end

// control module
AES_State aes_state(.*);

// key expansion
KeyExpansion key_exp(.clk(CLK), .Cipherkey(Key), .KeySchedule);

// logic modules
AddRoundKey add_key(.State_In(State), .Round(Round), .KeySchedule, .State_Out(AddRoundKeyOut));
InvShiftRows inv_shift(.data_in(State), .data_out(InvShiftRowsOut));
InvMixColumns_wrapper imc(.State_In(State), .State_Out(InvMixColumnsOut), .Column(Column));

// 16 sets of InvSubBytes for each byte of state
genvar index;  
generate  
for (index=0; index < 16; index=index+1)  
  begin: gen_code_label  
    InvSubBytes isb(.clk(CLK), .in(State[(8*(index+1))-1:(8*index)]), .out(InvSubByteOut[(8*(index+1))-1:(8*index)]));
  end  
endgenerate  




endmodule
