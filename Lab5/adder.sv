module full_adder(input x, y, z,
						output s, c);
	assign s = x^y^z;
	assign c = (x&y)|(y&z)|(x&z);

endmodule

module quad_adder(input [3:0] A,B,
						input c_in,
						output [3:0] S,
						output c_out);
	logic c1, c2, c3;
	full_adder FA1(.x(A[0]),.y(B[0]),.z(c_in), .s(S[0]), .c(c1));
	full_adder FA2(.x(A[1]),.y(B[1]),.z(c1), .s(S[1]), .c(c2));
	full_adder FA3(.x(A[2]),.y(B[2]),.z(c2), .s(S[2]), .c(c3));
	full_adder FA4(.x(A[3]),.y(B[3]),.z(c3), .s(S[3]), .c(c_out));
	
endmodule

module two_one_mux(input a, b, s, output y);
	assign y = (s) ? b : a;
endmodule

module quad_two_one_mux(input[3:0] a, b, input s, output[3:0] y);
	two_one_mux tw0(.a(a[0]), .b(b[0]), .s, .y(y[0]));
	two_one_mux tw1(.a(a[1]), .b(b[1]), .s, .y(y[1]));
	two_one_mux tw2(.a(a[2]), .b(b[2]), .s, .y(y[2]));
	two_one_mux tw3(.a(a[3]), .b(b[3]), .s, .y(y[3]));
endmodule

module adder_9bit( input [8:0]     A,
									input[8:0]     B,
									output[8:0]     Sum,
									output          CO );
	 logic c4;
	 quad_adder QA0(.A(A[3:0]), .B(B[3:0]), .c_in(1'b0), .S(Sum[3:0]), .c_out(c4));
	 
	 logic c8_0, c8_1, c8;
	 logic[3:0] qm1_0, qm1_1;
	 quad_adder QA1_0(.A(A[7:4]), .B(B[7:4]), .c_in(1'b0), .S(qm1_0), .c_out(c8_0));
	 quad_adder QA1_1(.A(A[7:4]), .B(B[7:4]), .c_in(1'b1), .S(qm1_1), .c_out(c8_1));
	 quad_two_one_mux QM1(.a(qm1_0), .b(qm1_1), .s(c4), .y(Sum[7:4]));
	 two_one_mux M1      (.a(c8_0),  .b(c8_1),  .s(c4), .y(c8));
	 
	 full_adder A9(.x(A[8]),.y(B[8]),.z(c8),.s(Sum[8]),.c(CO));
	 
endmodule

module add_sub(input logic[8:0] A, B,
					input logic Add,
					input logic Sub,
					output logic[8:0] Sum);
	
	logic[8:0] two_complement; // will get 2s comp of B
	logic[8:0] sum_add; // will get A + B
	logic[8:0] sum_sub; // will get A - B
	logic co1, co2, co3;
	
	// calculate 2s comp
	adder_9bit comp (.A(~B), .B(9'b000000001), .Sum(two_complement), .CO(co1));
	
	// calculate both add and subtracts
	adder_9bit add_adder (.A(A), .B(B), .Sum(sum_add), .CO(co2));
	adder_9bit sub_adder (.A(A), .B(two_complement), .Sum(sum_sub), .CO(co3));
	
	// chose the correct Sum we want based on inputs
	always_comb
	begin
		if(Add && ~Sub)
			Sum = sum_add;
		else if(Sub && ~Add)
			Sum = sum_sub;
		else 
			Sum = A;
	end
		
endmodule