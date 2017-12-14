module sprite_storage( input logic Clk,
							  input logic[9:0] VRAM_X, VRAM_Y,
							  input logic VRAM_READ_SPRITE,
							  input logic SPRITE_NUM,
							  input logic [7:0] VRAM_RGB;
							  
							  // SRAM control
							  output logic SRAM_CE_N, SRAM_UB_N, SRAM_LB_N, SRAM_OE_N, SRAM_WE_N,
							  output logic [19:0] SRAM_ADDR,
							  inout wire [15:0] SRAM_DQ 
							  );

logic [7:0] Sprite_1 [16960];
logic [7:0] Sprite_2 [16960];

logic p1_animation_lock, p2_animation_lock;

logic [9:0] h_counter_in, v_counter_in, h_counter, v_counter;
logic reading_sprite_2;
reading_sprite_2 = (v_counter >= 160) ? 1'b1 : 1'b0;

logic[15:0] addr_converted;
assign addr_converted = (h_counter + ((reading_sprite_2) ? v_counter - 160 : v_counter) * 106 );
							  
always_ff @ (posedge Clk) {
	if (DrawY == 481 && DrawX == 0) {
		counter <= 0;
		p1_animation_lock <= p1_animation;
		p2_animation_lock <= p2_animation;
		reading_sprite_2_2_2 <= 0; 
	}
	else if (DrawY > 480 && DrawY <= 525) {
		h_counter <= h_counter_in;
		v_counter <= v_counter_in;
		if (reading_sprite_2) Sprite_2[addr_converted] <= VRAM_RGB;
		else Sprite_1[addr_converted] <= VRAM_RGB;
	}
}

always_comb
begin
	// horizontal and vertical counter
	h_counter_in = h_counter + 10'd1;
	v_counter_in = v_counter;
	if(h_counter + 10'd1 == 10'd106)
		begin
			h_counter_in = 10'd0;
			if(v_counter + 10'd1 == 10'd320)
				 v_counter_in = 10'd0;
			else
				 v_counter_in = v_counter + 10'd1;
		end
end

logic [9:0] anim_offset_p1_x, anim_offset_p1_y, anim_offset_p2_x, anim_offset_p2_y;
animation_offset offset_p1(.animation(p1_animation), .offsetX(anim_offset_p1_x), .offsetY(anim_offset_p1_y));
animation_offset offset_p2(.animation(p2_animation), .offsetX(anim_offset_p2_x), .offsetY(anim_offset_p2_y));

logic VRAM_READ_SPRITE,
logic[9:0] VRAM_X, VRAM_Y,
logic[7:0] VRAM_RGB,
	
always_comb
begin
	if (DrawY > 480 && DrawY < 525) {
		VRAM_READ_SPRITE = 1;
		vram_x = h_counter + ((reading_sprite_2_2) ? anim_offset_p2_x : anim_offset_p1_x;
		vram_y = ((reading_sprite_2_2) ? v_counter - 160 : v_counter) + ((reading_sprite_2_2) ? anim_offset_p2_y : anim_offset_p1_y;
	}
	else if (VRAM_READ_SPRITE) {
		if (SPRITE_NUM) VRAM_RGB = Sprite_2[vramx_passthrough + vramy_passthrough * 106]
		else VRAM_RGB = Sprite_1[vramx_passthrough + vramy_passthrough * 106];
	}
	else {
		vram_x = vramx_passthrough;
		vram_y = vramy_passthrough;
	}
end


endmodule