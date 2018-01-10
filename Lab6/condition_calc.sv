module condition_calc(input logic Clk, Reset, input logic[15:0] IR, input logic[15:0] Bus, input logic LD_BEN, LD_CC, output logic BEN);
	logic N,Z,P;
	// internal register for nzp
	always_ff @(posedge Clk)
	begin
		// clearing internal registers to 0
		if (Reset)
			begin
				N <= 1'b0;
				Z <= 1'b0;
				P <= 1'b0;
				BEN <= 1'b0;
			end
		// when load cc, load nzp regs
		if (LD_CC)
			begin
				N <= (signed'(Bus) < 0);
				Z <= (signed'(Bus) == 0);
				P <= (signed'(Bus) > 0);
			end
		// load output ben reg
		if (LD_BEN)
				BEN <= (IR[11] & N) | (IR[10] & Z) | (IR[9] & P);
	end
endmodule	