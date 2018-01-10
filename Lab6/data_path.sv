module data_path (input logic[15:0] PC, MARMUX, ALU, MDR, 
						input logic GatePC, GateMDR, GateALU, GateMARMUX,
						output logic[15:0] Bus);
// data path will a mux that. "the bus" will just be the output of the mux
always_comb
begin
// choose the correct output of the mux based on the gates
	if (GatePC)
		Bus = PC;
	else if (GateMDR)
		Bus = MDR;
	else if (GateALU)
		Bus = ALU;
	else if (GateMARMUX)
		Bus = MARMUX;
	else
		Bus = 16'bZ;
end
endmodule