/* State Machine for AES Decryption
	Author: Jordan Wu
	Course: ECE385
*/

module AES_State (
	input	 logic CLK,
	input  logic RESET,
	input  logic AES_START,
	input  logic AES_DEBUG,
	input  logic AES_STEP,
	output logic AES_DONE,
	output logic AddKey_En, ShiftRow_En, SubByte_En, MixColumn_En, Initialization_En, Load_En,
	output logic[3:0] Round,
	output logic[1:0] Column,
	output logic SubByte_Read
);

    enum logic [5:0] {  Wait,
								Initialization,
                        KeyExpansion,
								FirstRound,
								LoopRounds,
								FinalRound,
								Done
								}   State, Next_state;   // Internal state logic

	 initial State = Wait; // set initial state

	 shortint KeyExpansion_States; // KeyExpansion will need to loop 10 times for result to be correct
	 shortint LoopRounds_States; // LoopRound will loop 9 times * 4 operations per round = 36
	 logic [3:0] FinalRound_States; // FinalRound has 3 operations
	 logic [1:0] MixColumn_States; // Mix column states
	 logic SubByte_State; // extra state for subByte

	 assign Column = MixColumn_States;
	 assign SubByte_Read = SubByte_State;

	 logic AES_STEP_last = 0;
	 assign Load_En = ~AES_DEBUG | AES_STEP == AES_STEP_last + 1; // Load_En, if we want to load new on this clock cycle

// set next states
always_ff @ (posedge CLK)
begin
	if (RESET)
		State <= Wait;
	else if (Load_En)
		State <= Next_state;
	AES_STEP_last <= AES_STEP;
end

// substate synchronous logic. Its a mess/not ideal but it works lol.
always_ff @ (posedge CLK)
begin
	if (Load_En)
	begin
	case (State)
		KeyExpansion :
			KeyExpansion_States <= KeyExpansion_States + 1;

		LoopRounds :
			if (LoopRounds_States % 4 == 3 & MixColumn_States != 2'b11) // mix columns 4 times on the 4th operation of LoopRounds
				MixColumn_States <= MixColumn_States + 1;
			else if (LoopRounds_States % 4 == 1 & SubByte_State != 1'b1) // SubBytes need 2 cycles
				SubByte_State <= SubByte_State + 1;
			else
			begin
				MixColumn_States <= 0;
				SubByte_State <= 0;
				LoopRounds_States <= LoopRounds_States + 1; // reset back to 0, and increment looprounds when done with mixing
			end

		FinalRound :
			if (FinalRound_States  == 1 & SubByte_State != 1'b1) // Final Round also needs 2 states of subbyte
				SubByte_State <= SubByte_State + 1;
			else
			begin
			FinalRound_States <= FinalRound_States + 1;
			SubByte_State <= 0;
			end

		default :
		begin
			KeyExpansion_States <= 0;
			LoopRounds_States <= 0;
			FinalRound_States <= 0;
			MixColumn_States <= 0;
			SubByte_State <= 0;
		end
	endcase
	end
end

always_comb
begin
	// Default next state is staying at current state
   Next_state = State;
	// Set Default Outputs
	AES_DONE = 0;
	AddKey_En = 0;
	ShiftRow_En = 0;
	SubByte_En = 0;
	MixColumn_En = 0;
	Initialization_En = 0;
	Round = 0;
	case (State) // state flow logic + output control logic

		Wait :
		begin
			if (AES_START) Next_state = Initialization;
			else Next_state = Wait;
		end

		Initialization:
		begin
			Next_state = KeyExpansion;
			Initialization_En = 1;
		end

		KeyExpansion :
		begin
			if (KeyExpansion_States == 20)
				Next_state = FirstRound;
		end

		FirstRound :
		begin
				Next_state = LoopRounds;
				AddKey_En = 1;
				Round = 4'd10;
		end
		LoopRounds :
		begin
			Round = 4'd9 - (LoopRounds_States/4);
			if (LoopRounds_States == 36)
				Next_state = FinalRound;
			else
			begin
				case (LoopRounds_States % 4)
					0: // perform shift row
						ShiftRow_En = 1;
					1: // perform sub byte
						SubByte_En = 1;
					2: // perform add round key
						AddKey_En = 1;
					3: // perform mix column
						MixColumn_En = 1;
				endcase
			end
		end

		FinalRound :
		begin
			case (FinalRound_States)
				0:
					ShiftRow_En = 1;
				1:
					SubByte_En = 1;
				2:
				begin
					Round = 0;
					AddKey_En = 1;
					Next_state = Done;
				end
			endcase
		end

		Done : // done will go back to wait when aes start drops
		begin
			AES_DONE = 1;
			if (AES_START) Next_state = Done;
			else Next_state = Wait;
		end

	endcase
end
endmodule
