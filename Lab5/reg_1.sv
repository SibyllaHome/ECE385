module reg_1 (input  logic Clk, Reset, Shift_In, Shift_En,
              output logic Shift_Out);

    always_ff @ (posedge Clk)
    begin
	 	 if (Reset) //notice, this is a sycnrhonous reset, which is recommended on the FPGA
			  Shift_Out <= 1'h0;
		 else if (Shift_En)
		 begin
			  //concatenate shifted in data to the previous left-most 3 bits
			  //note this works because we are in always_ff procedure block
			  Shift_Out <= Shift_In; 
	    end
    end

endmodule
