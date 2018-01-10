module AddRoundKey(input logic[127:0] State_In, input logic[3:0] Round, input logic[1407:0] KeySchedule, output logic[127:0] State_Out, output logic[127:0] RoundKey);

// get roundkey for round from keyschedule

always_comb
begin
	case (Round)
		4'd0: RoundKey = KeySchedule[(128*11)-1:(128*11)-128];
		4'd1: RoundKey = KeySchedule[(128*10)-1:(128*10)-128];
		4'd2: RoundKey = KeySchedule[(128*9)-1:(128*9)-128];
		4'd3: RoundKey = KeySchedule[(128*8)-1:(128*8)-128];
		4'd4: RoundKey = KeySchedule[(128*7)-1:(128*7)-128];
		4'd5: RoundKey = KeySchedule[(128*6)-1:(128*6)-128];
		4'd6: RoundKey = KeySchedule[(128*5)-1:(128*5)-128];
		4'd7: RoundKey = KeySchedule[(128*4)-1:(128*4)-128];
		4'd8: RoundKey = KeySchedule[(128*3)-1:(128*3)-128];
		4'd9: RoundKey = KeySchedule[(128*2)-1:(128*2)-128];
		4'd10: RoundKey = KeySchedule[127:0];
		default: RoundKey = KeySchedule[(128*11)-1:(128*11)-128];
	endcase
end

// xor with state in and output
assign State_Out = State_In ^ RoundKey;
endmodule