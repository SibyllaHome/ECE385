// 16 bit wide register fold holding IR, MDR, PC, various
module reg_16(input  logic Clk, Reset, Load,
              input  logic [15:0]  D_In,
              output logic [15:0]  D_Out);

    always_ff @ (posedge Clk)
    begin
	 	 if (Reset)
			  D_Out <= 16'h0;
		 else if (Load)
			  D_Out <= D_In;
    end


endmodule
