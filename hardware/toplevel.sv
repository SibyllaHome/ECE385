/************************************************************************
Lab 9 Quartus Project Top Level

Dong Kai Wang, Fall 2017
Christine Chen, Fall 2013

For use with ECE 385 Experiment 9
University of Illinois ECE Department
************************************************************************/

module toplevel (
	input  logic        CLOCK_50,
	input  logic [3:0]  KEY,
	output logic [7:0]  LEDG,
	output logic [17:0] LEDR,
	output logic [6:0]  HEX0,
	output logic [6:0]  HEX1,
	output logic [6:0]  HEX2,
	output logic [6:0]  HEX3,
	output logic [6:0]  HEX4,
	output logic [6:0]  HEX5,
	output logic [6:0]  HEX6,
	output logic [6:0]  HEX7,
	output logic [12:0] DRAM_ADDR,
	output logic [1:0]  DRAM_BA,
	output logic        DRAM_CAS_N,
	output logic        DRAM_CKE,
	output logic        DRAM_CS_N,
	inout  logic [31:0] DRAM_DQ,
	output logic [3:0]  DRAM_DQM,
	output logic        DRAM_RAS_N,
	output logic        DRAM_WE_N,
	output logic        DRAM_CLK,

	// PS2
	input  logic		PS2_KBCLK,
	input  logic		PS2_KBDAT,

	// VGA
	output logic [7:0]  VGA_R,        //VGA Red
						VGA_G,        //VGA Green
						VGA_B,        //VGA Blue
	output logic   VGA_CLK,      //VGA Clock
						VGA_SYNC_N,   //VGA Sync signal
						VGA_BLANK_N,  //VGA Blank signal
						VGA_VS,       //VGA virtical sync signal
						VGA_HS,       //VGA horizontal sync signal

	// SRAM passthrough
	output logic 		SRAM_CE_N, SRAM_UB_N, SRAM_LB_N, SRAM_OE_N, SRAM_WE_N,
	output logic [19:0] SRAM_ADDR,
	inout wire   [15:0] SRAM_DQ //tristate buffers need to be of type wire
);

logic [31:0] led_export;
//assign LEDR[15:0] = led_export[15:0];

// Instantiate Keyboard
logic [7:0] P1_Keycode, P2_Keycode;
logic [7:0] KEYCODE_RAW;
assign LEDG[7:0] = P1_Keycode;
assign LEDR[7:0] = P2_Keycode;
keyboard_controller kb_c_0(.CLK_50(CLOCK_50), .psClk(PS2_KBCLK), .psData(PS2_KBDAT), .RESET_H(~KEY[0]), .P1_Keycode, .P2_Keycode, .KEYCODE_RAW);

HexDriver hexdrv0 (
	.In(KEYCODE_RAW[3:0]),
   .Out(HEX0)
);
HexDriver hexdrv1 (
	.In(KEYCODE_RAW[7:4]),
   .Out(HEX1)
);

// synchronize software and hardware, such that software does 1 cycle per frame
logic frame_synchronizer = 0;
always_ff @ (posedge VGA_VS)
begin
	frame_synchronizer <= ~frame_synchronizer;
end

// Wires to connect nios system with gpu
logic [9:0]	 p1_X, p1_Y, p2_X, p2_Y, p1_width, p1_height, p2_width, p2_height, p1_health, p2_health, p1_animation, p2_animation;
logic p1_direction, p2_direction;

// Instantiation of Qsys design
nios_system system (
	.clk_clk(CLOCK_50),								// Clock input
	.reset_reset_n(1'b1),							// Reset key
	.sdram_wire_addr(DRAM_ADDR),					// sdram_wire.addr
	.sdram_wire_ba(DRAM_BA),						// sdram_wire.ba
	.sdram_wire_cas_n(DRAM_CAS_N),				// sdram_wire.cas_n
	.sdram_wire_cke(DRAM_CKE),						// sdram_wire.cke
	.sdram_wire_cs_n(DRAM_CS_N),					// sdram.cs_n
	.sdram_wire_dq(DRAM_DQ),						// sdram.dq
	.sdram_wire_dqm(DRAM_DQM),						// sdram.dqm
	.sdram_wire_ras_n(DRAM_RAS_N),				// sdram.ras_n
	.sdram_wire_we_n(DRAM_WE_N),					// sdram.we_n
	.sdram_clk_clk(DRAM_CLK),						// Clock out to SDRAM
	
	.export_VGA_VS(~VGA_VS),       				//     export.VGA_VS
	.export_P1_Keycode(P1_Keycode),   			//     export.P1_Keycode
	.export_P2_Keycode(P2_Keycode),  			//           .P2_Keycode
	.export_p1_x(p1_X),         					//           .p1_x
	.export_p1_y(p1_Y),         					//           .p1_y
	.export_p1_direction(p1_direction),
	.export_p1_width(p1_width),     				//           .p1_width
	.export_p1_height(p1_height),    			//           .p1_height
	.export_p1_health(p1_health),    			//           .p1_health
	.export_p1_animation(p1_animation), 		//           .p1_animation
	.export_p2_x(p2_X),         					//           .p2_x
	.export_p2_y(p2_Y),         					//           .p2_y
	.export_p2_direction(p2_direction),
	.export_p2_width(p2_width),     				//           .p2_width
	.export_p2_height(p2_height),    			//           .p2_height
	.export_p2_health(),    						//           .p2_health
	.export_p2_animation(p2_animation), 		//           .p2_animation
	.led_pio_out_export(led_export),					// PIO
	.vga_vs_pio_in_export(frame_synchronizer)
);

// Instantiate GPU
graphics_module graphics_0(.CLK_50(CLOCK_50), .RESET_H(~KEY[0]), .*);



endmodule
