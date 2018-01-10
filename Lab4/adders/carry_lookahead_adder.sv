module CLA_adder (input x, y, z,
						output s, p, g);
	assign g = x&y;
	assign p = x^y;
	assign s = x^y^z;
endmodule

module CLA_quad_adder(input [3:0] A, B,
							 input c_in,
							 output [3:0] s,
							 output p,g);
	// Internal carries in the 2-bit adder
	logic p0;
	logic p1;
	logic p2;
	logic p3;

	logic g0;
	logic g1;
	logic g2;
	logic g3;

	CLA_adder CA0 (.x (A[0]), .y (B[0]), .z (c_in), .s (s[0]), .p(p0), .g(g0));
	CLA_adder CA1 (.x (A[1]), .y (B[1]), .z (c_in & p0 | g0), .s (s[1]), .p(p1), .g(g1));
	CLA_adder CA2 (.x (A[2]), .y (B[2]), .z (c_in & p0 & p1 | g0 & p1 | g1), .s (s[2]), .p(p2), .g(g2));
	CLA_adder CA3 (.x (A[3]), .y (B[3]), .z (c_in & p0 & p1 & p2| g0 & p1 & p2 | g1 & p2 | g2), .s (s[3]), .p(p3), .g(g3));
	assign p = p0 & p1 & p2 & p3;
	assign g = g3|(g2&p3)|(g1&p3&p2)|(g0&p3&p2&p1);
endmodule



module carry_lookahead_adder (input [15:0] A, B,
 output [15:0] Sum,
 output CO);
// Internal carries in the 2-bit adder
	logic p0;
	logic p1;
	logic p2;
	logic p3;

	logic g0;
	logic g1;
	logic g2;
	logic g3;

	CLA_quad_adder CQA0(.A(A[3:0]), .B(B[3:0]), .c_in(1'b0), .s(Sum[3:0]), .p(p0), .g(g0));
	CLA_quad_adder CQA1(.A(A[7:4]), .B(B[7:4]), .c_in(g0 |(c_in & p0)), .s(Sum[7:4]), .p(p1), .g(g1));
	CLA_quad_adder CQA2(.A(A[11:8]), .B(B[11:8]), .c_in(g1 | (g0 & p1) | (c_in & p0 & p1)), .s(Sum[11:8]), .p(p2), .g(g2));
	CLA_quad_adder CQA3(.A(A[15:12]), .B(B[15:12]), .c_in(g2 | (g1 & p2) | (g0 & p2 & p1) | (c_in & p2 & p1 & p0)), .s(Sum[15:12]), .p(p3), .g(g3));

	assign CO = c_in & p0 & p1 & p2 & p3 | (g0 & p1 & p2 & p3) | (g1 & p2 & p3) | (g2 & p3) | g3;
	assign PG = p0 & p1 & p2 & p3;
	assign GG = g3 | (g2 & p3) | (g1 & p3 & p2) | (g0 & p3 & p2 & p1);
endmodule
