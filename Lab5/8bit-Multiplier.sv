module top_level_multiplier (input logic[7:0] S,
									  input logic Clk, Reset, Run, ClearA_LoadB,
									  output logic[6:0] AhexU, AhexL, BhexU, BhexL,
									  output[7:0] Aval,Bval,
									  output logic X);

// Wires
		logic ClearA, LoadB, Shift, Add, Sub;	
		logic AB_conn;
		logic M;
		logic X_in;

		logic[7:0] Sum;
		
		// controller instance
		control control_inst(.*, .Reset(~Reset), .Run(~Run), .ClearA_LoadB(~ClearA_LoadB));
		add_sub adder_inst(.A({Aval[7],Aval}), .B({S[7],S}), .Add, .Sub, .Sum({X_in,Sum}));
		
		// X REG_
		reg_1 X_REG(.Clk(Clk), .Reset(ClearA), .Shift_En((Add|Sub)&M), .Shift_In(X_in), .Shift_Out(X));
		  
		// registers, wired up according to block diagram
		// parallel loading from the ALU for A will be determined by whether M and Add or Sub are both 1, according to design
		reg_8 A_REG(.Clk(Clk),.Shift_En(Shift), .Reset(ClearA), .Load((Add&M)|(Sub&M)), .D(Sum),  .Shift_In(X),       .Shift_Out(AB_conn), .Data_Out(Aval));
		reg_8 B_REG(.Clk(Clk),.Shift_En(Shift), .Reset(1'b0),   .Load(LoadB),           .D(S),    .Shift_In(AB_conn), .Shift_Out(M),       .Data_Out(Bval));
		
		// hex drivers
		HexDriver   HexAL (
						.In0(Aval[3:0]),
						.Out0(AhexL) );
		HexDriver   HexBL (
						.In0(Bval[3:0]),
						.Out0(BhexL) );
		HexDriver   HexAU (
						.In0(Aval[7:4]),
						.Out0(AhexU) );	
		HexDriver   HexBU (
						.In0(Bval[7:4]),
						.Out0(BhexU) );
	
endmodule
