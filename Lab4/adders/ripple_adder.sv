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

module hex_adder(input [15:0] A,B,
						input c_in,
						output [15:0] S,
						output c_out);
	logic c1, c2, c3;
	quad_adder QA_4_1(.A(A[3:0]),.B(B[3:0]),.c_in(c_in), .S(S[3:0]), .c_out(c1));
	quad_adder QA_4_2(.A(A[7:4]),.B(B[7:4]),.c_in(c1), .S(S[7:4]), .c_out(c2));
	quad_adder QA_4_3(.A(A[11:8]),.B(B[11:8]),.c_in(c2), .S(S[11:8]), .c_out(c3));
	quad_adder QA_4_4(.A(A[15:12]),.B(B[15:12]),.c_in(c3), .S(S[15:12]), .c_out(c_out));
	
endmodule

module ripple_adder
(
    input   logic[15:0]     A,
    input   logic[15:0]     B,
    output  logic[15:0]     Sum,
    output  logic           CO
);

    /* TODO
     *
     * Insert code here to implement a ripple adder.
     * Your code should be completly combinational (don't use always_ff or always_latch).
     * Feel free to create sub-modules or other files. */
	 hex_adder ha(.A(A),.B(B),.S(Sum),.c_out(CO),.c_in(1'b0));

     
endmodule
