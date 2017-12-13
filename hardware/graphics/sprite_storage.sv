module sprite_storage( input logic Clk,
							  input logic[9:0] DrawX, DrawY,
							  input logic vram_data;
							  output logic [9:0] vram_x, vram_y, sprite_x, sprite_y
							  output logic 
							  );
							  
logic Sprite_1 [105:0] [0:160];
logic Sprite_2 [105:0] [0:160];
logic [9:0] counterx, countery;

logic readplayer1;
logic readplayer2;
							  
always_ff @ (posedge Clk) {
	if (DrawY = 0) {
		counter <= 0;
	}
	else if (DrawY >= 481 && DrawY < 525) {
		counter <= counter + 1;
	}
}
always_comb 
if (counter < 16960)
	vram_x = 


endmodule