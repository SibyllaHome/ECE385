//Two-always example for state machine

module control (input  logic Clk, Reset, Run, ClearA_LoadB, 
                output logic ClearA, LoadB, Shift, Add, Sub);

    // Declare signals curr_state, next_state of type enum
    // with enum values of A, B, ..., F as the state values
	 // Note that the length implies a max of 8 states, so you will need to bump this up for 8-bits
    enum logic [4:0] {A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, CLR} curr_state, next_state; 

	//updates flip flop, current state is the only one
    always_ff @ (posedge Clk)  
    begin
        if (Reset)
            curr_state <= A;
        else 
            curr_state <= next_state;
    end

    // Assign outputs based on state
	always_comb
    begin
			// default outputs cuz lazy
			next_state  = curr_state;
			Shift = 1'b0;
			Add = 1'b0;
			Sub = 1'b0;
			ClearA = 1'b0;
			LoadB = 1'b0;
		  
        unique case (curr_state) 

            A :    if (Run)
							next_state = CLR;
				CLR:   next_state = B;
            B :    next_state = C;
            C :    next_state = D;
            D :    next_state = E;
            E :    next_state = F;
				F :    next_state = G;
            G :    next_state = H;
            H :    next_state = I;
            I :    next_state = J;
				J :    next_state = K;
            K :    next_state = L;
            L :    next_state = M;
            M :    next_state = N;
				N :    next_state = O;
            O :    next_state = P;
            P :    next_state = Q;
            Q :    next_state = R;
            R :    if (~Run) 
                       next_state = A;
							  
        endcase
   
		  // Assign outputs based on ‘state’
        case (curr_state) 
	   	   A: 
	         begin
                LoadB = ClearA_LoadB;
					 ClearA = ClearA_LoadB;
		      end
				// going through the states should alternate between adding and shifting. Final "add" will be a subtraction
				// half of the states will be for adding
				CLR: // extra state at the beginning to clear A
					ClearA = 1'b1;
				B: 
					Add = 1'b1;
				D: 
					Add = 1'b1;
				F: 
					Add = 1'b1;
				H: 
					Add = 1'b1;
				J: 
					Add = 1'b1;
				L: 
					Add = 1'b1;
				N:  
					Add = 1'b1;
				P:  
					Sub = 1'b1;
				///////////////////
				C:	// half of the states for shifting
					Shift = 1'b1;
				E:
					Shift = 1'b1;
				G:
					Shift = 1'b1;
				I:
					Shift = 1'b1;
				K:
					Shift = 1'b1;
				M:
					Shift = 1'b1;
				O:
					Shift = 1'b1;
				Q:
					Shift = 1'b1;
				////////////////////
        endcase
    end

endmodule
