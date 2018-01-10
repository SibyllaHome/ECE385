// toplevel for graphics module


module graphics_module(
				// VGA Passthroughs
				input  logic         CLK_50, RESET_H,
				output logic [7:0]   VGA_R,        //VGA Red
											VGA_G,        //VGA Green
											VGA_B,        //VGA Blue
				output logic   		VGA_CLK,      //VGA Clock
											VGA_SYNC_N,   //VGA Sync signal
											VGA_BLANK_N,  //VGA Blank signal
											VGA_VS,       //VGA virtical sync signal
											VGA_HS,       //VGA horizontal sync signal
				// SRAM Passthroughs
				output logic 			SRAM_CE_N, SRAM_UB_N, SRAM_LB_N, SRAM_OE_N, SRAM_WE_N,
				output logic [19:0] 	SRAM_ADDR,
				inout wire   [15:0] 	SRAM_DQ, //tristate buffers need to be of type wire
				// Player Data
				input logic  [9:0]	p1_X, p1_Y, p2_X, p2_Y, p1_width, p1_height, p2_width, p2_height, p1_health, p2_health, p1_animation, p2_animation,
				input logic p1_direction, p2_direction
);

	logic CLK_25 = 0;
	assign VGA_CLK = CLK_25;
	always_ff @ (posedge CLK_50) begin
        CLK_25 <= ~CLK_25;
	end

	logic[9:0] DrawX, DrawY;

	// VGA hardware controller
	VGA_controller vga_controller_instance(.Clk(CLK_50), .Reset(RESET_H), .VGA_HS, .VGA_VS, .VGA_CLK(VGA_CLK), .VGA_BLANK_N, .VGA_SYNC_N, .DrawX, .DrawY);

	// VRAM Control
	logic VRAM_READ_SPRITE;
	logic [9:0] VRAM_X, VRAM_Y;
	// VRAM output
	logic [7:0] VRAM_RGB;

	// SPRITE Data
	// characters are 106x160
	logic[7:0] SPRITE_TRANSPARENT_COLOR = 8'hfc;
	
	GPU gpu_instance(.*, .SPRITE_WIDTH(p1_width), .SPRITE_HEIGHT(p1_height));

	VRAM vram_instance(.*);

	// TEST SRAM for simulation
	// test_memory tm_inst(.Clk(CLK_50), .Reset(RESET_H), .I_O(SRAM_DQ), .A(SRAM_ADDR), .CE(SRAM_CE_N), .UB(SRAM_UB_N), .LB(SRAM_LB_N), .OE(SRAM_OE_N), .WE(SRAM_WE_N));
endmodule
