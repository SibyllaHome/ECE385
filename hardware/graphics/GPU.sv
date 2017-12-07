//-------------------------------------------------------------------------
//    Color_Mapper.sv                                                    --
//    Stephen Kempf                                                      --
//    3-1-06                                                             --
//                                                                       --
//    Modified by David Kesler  07-16-2008                               --
//    Translated by Joe Meng    07-07-2013                               --
//    Modified by Po-Han Huang  10-06-2017                               --
//                                                                       --
//    Fall 2017 Distribution                                             --
//                                                                       --
//    For use with ECE 385 Lab 8                                         --
//    University of Illinois ECE Department                              --
//-------------------------------------------------------------------------

// color_mapper: Decide which color to be output to VGA for each pixel.
module GPU (
					// 25MHz VGA clock and 100MHz memory clock
					input	logic VGA_CLK,
					// VGA draw location
					input	logic	[9:0] DrawX, DrawY,
					// Data from CPU
					input	logic	[9:0] p1_X, p1_Y, p2_X, p2_Y,
					input	logic	[9:0] p1_animation, p2_animation,
					// VRAM Control signals
					output	logic VRAM_READ_SPRITE,
					output	logic[9:0] VRAM_X, VRAM_Y,
					input 	logic[7:0] VRAM_RGB,
					// Constants for Sprite Data
					input	logic[9:0] SPRITE_WIDTH,
					input	logic[9:0] SPRITE_HEIGHT,
					input	logic[7:0] SPRITE_TRANSPARENT_COLOR,
					// VGA_RGB output
					output	logic [7:0] VGA_R, VGA_G, VGA_B
);

	enum logic [1:0] {ReadBG, ReadSPRITE} State, Next_State;

	// assign lower bits to 0
	assign VGA_R[4:0] = 0;
	assign VGA_G[4:0] = 0;
	assign VGA_B[5:0] = 0;

	// temporary rgb value store in the middle of each vga clock cycle
	logic[7:0] Temp_RGB;
	logic Temp_is_Transparent;
	assign Temp_is_Transparent = (Temp_RGB == SPRITE_TRANSPARENT_COLOR);
   assign neg_VGA_CLK = ~VGA_CLK; 
	
	always_ff @ (negedge VGA_CLK) // Latch Temporary RGB value mid - VGA clock
	begin
	Temp_RGB <= VRAM_RGB;
	end

	always_ff @ (posedge VGA_CLK) // Latch RGB at start of VGA clock
	begin
	{VGA_R[7:5], VGA_G[7:5], VGA_B[7:6]} <= VRAM_RGB;
	end

	// Increment original DrawX by 1 since the RGB value will be 1 VGA_Clock late
	logic [9:0] DrawX_Inc, DrawY_Inc;
	always_comb
	begin
		if(DrawX == 799) // increase vertically
		begin
			DrawX_Inc = 0;
			if (DrawY == 524) DrawY_Inc = 0;
			else DrawY_Inc = DrawY + 1;
		end
		else
		begin // increase horizontally
			DrawX_Inc = DrawX + 1;
			DrawY_Inc = DrawY;
		end
	end

	// Check in in sprite's bounds
	logic in_p1_bound, in_p2_bound;
	assign in_p1_bound = (p1_X < DrawX_Inc + SPRITE_WIDTH && DrawX_Inc < p1_X + SPRITE_WIDTH && p1_Y < DrawY_Inc + SPRITE_HEIGHT && DrawY_Inc < p1_Y + SPRITE_HEIGHT);
	assign in_p2_bound = (p2_X < DrawX_Inc + SPRITE_WIDTH && DrawX_Inc < p2_X + SPRITE_WIDTH && p2_Y < DrawY_Inc + SPRITE_HEIGHT && DrawY_Inc < p2_Y + SPRITE_HEIGHT);

    // VRAM Control logic
	always_comb
	begin
		State = ReadBG;
		VRAM_X = DrawX_Inc;
		VRAM_Y = DrawY_Inc;
		VRAM_READ_SPRITE = 0;

		// if in bound, read character on vga_CLK = 1 (first half of this frame)
		// on second half of this frame, if what we read was not transparent, keep reading the sprite
		if (in_p1_bound && (VGA_CLK == 1 || (VGA_CLK == 0 && ~Temp_is_Transparent)))
		begin
			State = ReadSPRITE;
			VRAM_X = DrawX_Inc - p1_X + SPRITE_WIDTH;
			VRAM_Y = DrawY_Inc - p1_Y + SPRITE_HEIGHT;
			VRAM_READ_SPRITE = 1;
		end
		// same logic for p2, p1 takes priority over p2
		else if (in_p2_bound && (VGA_CLK == 1 || (VGA_CLK == 0 && ~Temp_is_Transparent)))
		begin
			State = ReadSPRITE;
			// invert how we read p2's X, since p2 will be facing p1
			VRAM_X = - DrawX_Inc + p2_X + SPRITE_WIDTH;
			VRAM_Y = DrawY_Inc - p2_Y + SPRITE_HEIGHT;
			VRAM_READ_SPRITE = 1;
		end
	end
endmodule
