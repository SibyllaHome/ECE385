// register file 16-word 8-bit
module reg_file(	input Clk, Reset,
						input logic[15:0] In, 
						input logic LD_REG,
						input logic[2:0] DR_addr,
						input logic[2:0] SR1_addr,
						input logic[2:0] SR2_addr,
						output logic[15:0] SR1_out,
						output logic[15:0] SR2_out
);
	logic [15:0] regs [0:7];
	
	// sequential logic for resetting and parallel loading
	always_ff @ (posedge Clk)
	begin
		if (Reset)
			begin
			regs[0] <= 16'h0;
			regs[1] <= 16'h0;
			regs[2] <= 16'h0;
			regs[3] <= 16'h0;
			regs[4] <= 16'h0;
			regs[5] <= 16'h0;
			regs[6] <= 16'h0;
			regs[7] <= 16'h0;
			end
		else if (LD_REG)
			regs[DR_addr] <= In;
	end
	
	// combinational logic for setting output
	assign SR1_out = regs[SR1_addr];
	assign SR2_out = regs[SR2_addr];
	
endmodule