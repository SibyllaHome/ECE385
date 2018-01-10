module LED_controller(input logic Clk, input logic[15:0] IR, input logic LD_LED, output logic[11:0] LED);
	// put IR[11:0] on led whenever ld_led is 1; else clear led
	always_ff @ (posedge Clk)
	begin
		if (LD_LED)
			LED <= IR[11:0];
		else
			LED <= 12'b0;
	end

endmodule