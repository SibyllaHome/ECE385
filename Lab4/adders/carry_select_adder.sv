module two_one_mux(input a, b, s, output y);
	assign y = (s) ? b : a;
endmodule

module quad_two_one_mux(input[3:0] a, b, input s, output[3:0] y);
	two_one_mux tw0(.a(a[0]), .b(b[0]), .s, .y(y[0]));
	two_one_mux tw1(.a(a[1]), .b(b[1]), .s, .y(y[1]));
	two_one_mux tw2(.a(a[2]), .b(b[2]), .s, .y(y[2]));
	two_one_mux tw3(.a(a[3]), .b(b[3]), .s, .y(y[3]));
endmodule

module carry_select_adder( input [15:0]     A,
									input[15:0]     B,
									output[15:0]     Sum,
									output          CO );
	 logic c4;
    quad_adder QA0(.A(A[3:0]), .B(B[3:0]), .c_in(1'b0), .S(Sum[3:0]), .c_out(c4));
	 
	 logic c8_0, c8_1, c8;
	 logic[3:0] qm1_0, qm1_1;
	 quad_adder QA1_0(.A(A[7:4]), .B(B[7:4]), .c_in(1'b0), .S(qm1_0), .c_out(c8_0));
	 quad_adder QA1_1(.A(A[7:4]), .B(B[7:4]), .c_in(1'b1), .S(qm1_1), .c_out(c8_1));
	 quad_two_one_mux QM1(.a(qm1_0), .b(qm1_1), .s(c4), .y(Sum[7:4]));
	 two_one_mux M1      (.a(c8_0),  .b(c8_1),  .s(c4), .y(c8));
	 
	 logic c12_0, c12_1, c12;
	 logic[3:0] qm2_0, qm2_1;
	 quad_adder QA2_0(.A(A[11:8]), .B(B[11:8]), .c_in(1'b0), .S(qm2_0), .c_out(c12_0));
	 quad_adder QA2_1(.A(A[11:8]), .B(B[11:8]), .c_in(1'b1), .S(qm2_1), .c_out(c12_1));
	 quad_two_one_mux QM2(.a(qm2_0), .b(qm2_1), .s(c8), .y(Sum[11:8]));
	 two_one_mux M2      (.a(c12_0), .b(c12_1), .s(c8), .y(c12));
	 
	 logic cout_0, cout_1;
	 logic[3:0] qm3_0, qm3_1;
	 quad_adder QA3_0(.A(A[15:12]), .B(B[15:12]), .c_in(1'b0), .S(qm3_0), .c_out(cout_0));
	 quad_adder QA3_1(.A(A[15:12]), .B(B[15:12]), .c_in(1'b1), .S(qm3_1), .c_out(cout_1));
	 quad_two_one_mux QM3(.a(qm3_0), .b(qm3_1), .s(c12), .y(Sum[15:12]));
	 two_one_mux M3(.a(cout_0), .b(cout_1), .s(c12), .y(CO)); 
	 
endmodule
