module keyboard_controller (input logic CLK_50, psClk, psData, RESET_H,
									 output logic [7:0] P1_Keycode, P2_Keycode, KEYCODE_RAW
									 );
logic[7:0] keyCode;
logic press;
logic neg_press;
assign neg_press = ~press;

assign KEYCODE_RAW = keyCode;

always_ff @ (posedge CLK_50)
begin
	if (RESET_H)
	begin
		for (int i = 0; i < 8; i++)
		begin
			P1_Keycode[i] <= 0;
			P2_Keycode[i] <= 0;
		end
	end
	case(keyCode)
		// W
		8'h1d:
		P1_Keycode[0] <= press;
		// A
		8'h1c:
		P1_Keycode[1] <= press;
		// S
		8'h1b:
		P1_Keycode[2] <= press;
		// D
		8'h23:
		P1_Keycode[3] <= press;
		// J
		8'h42:
		P1_Keycode[6] <= press;
		// K
		8'h3b:
		P1_Keycode[7] <= press;
		
		// Up
		8'h75:
		P2_Keycode[0] <= press;
		// Left
		8'h6b:
		P2_Keycode[1] <= press;
		// Down
		8'h72:
		P2_Keycode[2] <= press;
		// Right
		8'h74:
		P2_Keycode[3] <= press;
		// KP_-
		8'h7b:
		P2_Keycode[6] <= press;
		// KP_*
		8'h7c:
		P2_Keycode[7] <= press;
	endcase
end


// synchronize psClk and psData
logic psClk_s, psData_s;

always_ff @ (posedge CLK_50)
begin
	psClk_s <= psClk;
	psData_s <= psData;
end

keyboard kb_0(.Clk(CLK_50), .psClk(psClk_s), .psData(psData_s), .reset(RESET_H), .keyCode, .press);

endmodule