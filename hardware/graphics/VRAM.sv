module VRAM (
	// VRAM Interface
	input logic VRAM_READ_SPRITE,
	input logic[9:0] VRAM_X, VRAM_Y,
	output logic[7:0] VRAM_RGB,
	// SRAM control
	output logic SRAM_CE_N, SRAM_UB_N, SRAM_LB_N, SRAM_OE_N, SRAM_WE_N,
	output logic [19:0] SRAM_ADDR,
	inout wire [15:0] SRAM_DQ 
	);
	
	enum logic [1:0] { Halt, Read } State, Next_State;
	
	parameter [19:0] BG_OFFSET = 20'd0;
	parameter [19:0] SPRITE_OFFSET = BG_OFFSET + 20'd38400;
	
   // downscale width and height by half
	logic[8:0] downscale_X, downscale_Y;
	assign downscale_X = VRAM_X[9:1];
	assign downscale_Y = VRAM_Y[9:1];
	
	// convert into x,y row major index
	logic[19:0] addr_converted;
	assign addr_converted = (downscale_X + (downscale_Y * 320));
	
	// check whether enable upper or lower since were using 8-bit color
	logic upperEn_N, lowerEn_N;
	assign upperEn_N = addr_converted[0];
	assign lowerEn_N = ~addr_converted[0];
	
	// assign sram control to default
	assign SRAM_CE_N = 1'b0; // enable these
	assign SRAM_UB_N = 1'b0;
	assign SRAM_LB_N = 1'b0;
	assign SRAM_WE_N = 1'b1; // disable writing to SRAM
	assign SRAM_OE_N = 1'b0; // output always enabled
	assign SRAM_ADDR = addr_converted[19:1] + ((VRAM_READ_SPRITE) ? SPRITE_OFFSET : BG_OFFSET); // assign address using downscaled 8-bit data
	
	// Data signals from tristate buffer
	logic[16:0] Data_to_SRAM, Data_from_SRAM;
	
	// assign data from sram into rgb, no need for tristate since we won't be writing to sram from hardware
	assign VRAM_RGB = (~upperEn_N) ? SRAM_DQ[15:8] : SRAM_DQ[7:0];
endmodule
			