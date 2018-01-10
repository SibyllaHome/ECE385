module four_one_mux
						  (input logic [15:0] A, B, C, D,
							input logic [1:0] S,
							output logic [15:0] Y);
// four to one mux
always_comb
begin
	case (S)
		2'b00: Y = A;
		2'b01: Y = B;
		2'b10: Y = C;
		2'b11: Y = D;
		default: Y = 16'hxxxx;
	endcase
end
endmodule
