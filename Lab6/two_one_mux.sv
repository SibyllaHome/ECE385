// 2 to 1 mux self explainitory
module two_one_mux
						#(parameter width = 3)
						(input logic [width-1:0] A, B,
						input logic S,
						output logic [width-1:0] Y);
	always_comb begin
		if (S)
		Y = B; // choose b if s = 1
		else
		Y = A; // choose a if 0
	end
endmodule