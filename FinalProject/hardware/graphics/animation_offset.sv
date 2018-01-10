module animation_offset(input logic[9:0] animation, output logic[9:0] offsetX, output logic[9:0] offsetY);
always_comb
begin
	case (animation)
	10'd0:
	begin
	offsetX = 0;
	offsetY = 0;
	end
	10'd1:
	begin
	offsetX = 106;
	offsetY = 0;
	end
	10'd2:
	begin
	offsetX = 212;
	offsetY = 0;
	end
	10'd3:
	begin
	offsetX = 318;
	offsetY = 0;
	end
	10'd4:
	begin
	offsetX = 424;
	offsetY = 0;
	end
	10'd5:
	begin
	offsetX = 530;
	offsetY = 0;
	end
	10'd6:
	begin
	offsetX = 0;
	offsetY = 160;
	end
	10'd7:
	begin
	offsetX = 106;
	offsetY = 160;
	end
	10'd8:
	begin
	offsetX = 212;
	offsetY = 160;
	end
	10'd9:
	begin
	offsetX = 318;
	offsetY = 160;
	end
	10'd10:
	begin
	offsetX = 424;
	offsetY = 160;
	end
	10'd11:
	begin
	offsetX = 530;
	offsetY = 160;
	end
	10'd12:
	begin
	offsetX = 0;
	offsetY = 320;
	end
	10'd13:
	begin
	offsetX = 106;
	offsetY = 320;
	end
	10'd14:
	begin
	offsetX = 212;
	offsetY = 320;
	end
	10'd15:
	begin
	offsetX = 318;
	offsetY = 320;
	end
	10'd16:
	begin
	offsetX = 424;
	offsetY = 320;
	end
	10'd17:
	begin
	offsetX = 530;
	offsetY = 320;
	end
	default:
	begin
	offsetX = 0;
	offsetY = 0;
	end
	endcase
end
endmodule