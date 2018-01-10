module register_unit (input  logic Clk, Reset, A_In, B_In, Ld_A, Ld_B, 
                            Shift_En,
                      input  logic [7:0]  D, 
                      output logic A_out, B_out, 
                      output logic [7:0]  A,
                      output logic [7:0]  B);

	 logic a_conn;
	 logic b_conn;
    
//	 reg_4  reg_A_right (.*, .D(D[3:0]), .Shift_In(a_conn), .Load(Ld_A),
//	               .Shift_Out(A_out), .Data_Out(A[3:0]));
//	 
//	 reg_4  reg_A_left  (.*, .D(D[7:4]), .Shift_In(A_In), .Load(Ld_A),
//	               .Shift_Out(a_conn), .Data_Out(A[7:4]));
//    
//	 reg_4  reg_B_right (.*, .D(D[3:0]), .Shift_In(b_conn), .Load(Ld_B),
//	               .Shift_Out(B_out), .Data_Out(B[3:0]));
//	 
//	 reg_4  reg_B_left  (.*, .D(D[7:4]), .Shift_In(B_In), .Load(Ld_B),
//	               .Shift_Out(b_conn), .Data_Out(B[7:4]));

	reg_8 reg_A (.*, .D, .Shift_In(A_In), .Load(Ld_A),
	             .Shift_Out(A_out), .Data_Out(A));
	reg_8 reg_B (.*, .D, .Shift_In(B_In), .Load(Ld_B),
	             .Shift_Out(B_out), .Data_Out(B));

endmodule
