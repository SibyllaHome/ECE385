// alu module. operations are self explanitory
module ALU (input logic[15:0] A, B, input logic[1:0] ALUK, output logic[15:0] ALU_out);
always_comb
begin
	case (ALUK)
		2'b00: ALU_out = A + B; //add when s == 00
		2'b01: ALU_out = A & B; //and when s == 01
		2'b10: ALU_out = ~A;    //not when s == 10
		2'b11: ALU_out = A;     //passthru when 11
		default: ALU_out = 16'hxxxx;
	endcase
end
endmodule
