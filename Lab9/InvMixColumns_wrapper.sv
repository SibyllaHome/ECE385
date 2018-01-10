// wraps invMixColumns so can  select which column to apply function on.

module InvMixColumns_wrapper(input logic [127:0] State_In, input logic[1:0] Column, output logic [127:0] State_Out); 

logic[31:0] Mix_Column_In, Mix_Column_Out;

InvMixColumns mixer(.in(Mix_Column_In), .out(Mix_Column_Out));

always_comb
begin
	State_Out = State_In;
	case(Column) // mix the column
		2'd0:
		begin
			Mix_Column_In = State_In[127:96];
			State_Out[127:96] = Mix_Column_Out;
		end
		2'd1:
		begin
			Mix_Column_In = State_In[95:64];
			State_Out[95:64] = Mix_Column_Out;
		end
		2'd2:
		begin
			Mix_Column_In = State_In[63:32];
			State_Out[63:32] = Mix_Column_Out;
		end
		2'd3:
		begin	
			Mix_Column_In = State_In[31:0];
			State_Out[31:0] = Mix_Column_Out;
		end
	endcase
end
endmodule