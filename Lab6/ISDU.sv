//------------------------------------------------------------------------------
// Company:          UIUC ECE Dept.
// Engineer:         Stephen Kempf
//
// Create Date:    17:44:03 10/08/06
// Design Name:    ECE 385 Lab 6 Given Code - Incomplete ISDU
// Module Name:    ISDU - Behavioral
//
// Comments:
//    Revised 03-22-2007
//    Spring 2007 Distribution
//    Revised 07-26-2013
//    Spring 2015 Distribution
//    Revised 02-13-2017
//    Spring 2017 Distribution
//------------------------------------------------------------------------------


module ISDU (   input logic         Clk, 
                                    Reset,
                                    Run,
                                    Continue,
                                    
                input logic[3:0]    Opcode, 
                input logic         IR_5,
                input logic         IR_11,
                input logic         BEN,
                  
                output logic        LD_MAR,
                                    LD_MDR,
                                    LD_IR,
                                    LD_BEN,
                                    LD_CC,
                                    LD_REG,
                                    LD_PC,
                                    LD_LED, // for PAUSE instruction
                                    
                output logic        GatePC,
                                    GateMDR,
                                    GateALU,
                                    GateMARMUX,
                                    
                output logic [1:0]  PCMUX,
                output logic        DRMUX,
                                    SR1MUX,
                                    SR2MUX,
                                    ADDR1MUX,
                output logic [1:0]  ADDR2MUX,
                                    ALUK,
                  
                output logic        Mem_CE,
                                    Mem_UB,
                                    Mem_LB,
                                    Mem_OE,
                                    Mem_WE
                );

    enum logic [5:0] {  Halted, 
                        PauseIR1, 
                        PauseIR2, 
                        S_18, 
                        S_33_1, 
                        S_33_2, 
                        S_35, 
                        S_32, 
                        S_01, S_05, S_09, 
								S_06, S_25_1, S_25_2, S_27,
								S_07, S_23, S_16_1, S_16_2,
								S_00, S_22,
								S_04, S_21,
								S_12}   State, Next_state;   // Internal state logic
        
    always_ff @ (posedge Clk)
    begin
        if (Reset) 
            State <= Halted;
        else 
            State <= Next_state;
    end
   
    always_comb
    begin 
        // Default next state is staying at current state
        Next_state = State;
			// STATE FLOW
        unique case (State)
            Halted : 
                if (Run) 
                    Next_state = S_18;                      
            S_18 : 
                Next_state = S_33_1;
            // Any states involving SRAM require more than one clock cycles.
            // The exact number will be discussed in lecture.
            S_33_1 : 
                Next_state = S_33_2;
            S_33_2 : 
                Next_state = S_35;
            S_35 : 
                Next_state = S_32;
				// decode opcode after IR has beeen loaded with instruction
            S_32 : 
                case (Opcode)
                  4'b0001 : // ADD goes to S01
							Next_state = S_01;
						4'b0101 : // AND goes to S05
							Next_state = S_05;
						4'b1001 : // NOT goes to S09
							Next_state = S_09;
                  4'b0110 : // LDR goes to s06
							Next_state = S_06;
						4'b0111: // str goes to s07
							Next_state = S_07;
						4'b0000: // BR goes to s00
							Next_state = S_00;
						4'b0100: // JSR goes to s04
							Next_state = S_04;
						4'b1100: // JMP goes to s12
							Next_state = S_12;
						4'b1101: // PauseIR state
							Next_state = PauseIR1;

                    default : 
                        Next_state = S_18;
                endcase
				// ADD AND NOT STATES
            S_01 : 
                Next_state = S_18;
				S_05 : 
                Next_state = S_18;
				S_09 : 
                Next_state = S_18;
			   // LDR STATES
				S_06 :
					 Next_state = S_25_1;
				S_25_1 :
					 Next_state = S_25_2;
				S_25_2 :
					 Next_state = S_27;
				S_27 :
					 Next_state = S_18;
				// STR STATES
				S_07 :
					 Next_state = S_23;
				S_23 :
					 Next_state = S_16_1;
				S_16_1 :
					 Next_state = S_16_2;
				S_16_2 :
					 Next_state = S_18;
				// BR STATES
				S_00 : 
					 if (BEN)
						Next_state = S_22;
					 else
						Next_state = S_18;
				S_22 :
					 Next_state = S_18;
				// JSR States
				S_04 :
					 Next_state = S_21;
				S_21 :
					 Next_state = S_18;
				// JMP States
				S_12 :
					 Next_state = S_18;
				// Pause States flow
				PauseIR1 : 
                if (~Continue) 
                    Next_state = PauseIR1;
                else 
                    Next_state = PauseIR2;
            PauseIR2 : 
                if (Continue) 
                    Next_state = PauseIR2;
                else 
                    Next_state = S_18;
            default : ;

        endcase

        // default controls signal values; within a process, these can be
        // overridden further down (in the case statement, in this case)
        LD_MAR = 1'b0;
        LD_MDR = 1'b0;
        LD_IR = 1'b0;
        LD_BEN = 1'b0;
        LD_CC = 1'b0;
        LD_REG = 1'b0;
        LD_PC = 1'b0;
        LD_LED = 1'b0;
         
        GatePC = 1'b0;
        GateMDR = 1'b0;
        GateALU = 1'b0;
        GateMARMUX = 1'b0;
         
        ALUK = 2'b00;
         
        PCMUX = 2'b00;
        DRMUX = 1'b0;
        SR1MUX = 1'b0;
        SR2MUX = 1'b0;
        ADDR1MUX = 1'b0;
        ADDR2MUX = 2'b00;
         
			// these are active low, set to 0 when we want to use it
        Mem_OE = 1'b1;
        Mem_WE = 1'b1;
        
		  // STATE OUTPUT
        // Assign control signals based on current state
        case (State)
            Halted: ;
            S_18 : 
                begin 
                    GatePC = 1'b1;
                    LD_MAR = 1'b1;
                    PCMUX = 2'b00;
                    LD_PC = 1'b1;
						  Mem_OE = 1'b0; // set 1 state early since synchronizer will delay by one clock cycle
                end
            S_33_1 : 
                Mem_OE = 1'b0; // set memory to drive output
            S_33_2 : 
                begin 
                    Mem_OE = 1'b0; // set memory to drive output
                    LD_MDR = 1'b1; // get MDR to load
                end
            S_35 : 
                begin 
                    GateMDR = 1'b1;
                    LD_IR = 1'b1;
                end
            S_32 : 
                LD_BEN = 1'b1;
				// STILL NEED TO SET CC FOR ALL OF THESE
				// Register manipulation control
            S_01 : 
                begin 
						  SR1MUX = 1'b0; // select input address of sr1, which will be lower bits
                    SR2MUX = IR_5; // select mode for sr2mux
                    ALUK = 2'b00; // set alu to add
                    GateALU = 1'b1; // open gate
						  DRMUX = 1'b0; // select address
                    LD_REG = 1'b1;// load
						  LD_CC = 1'b1; // setCC
                end
				S_05 : 
                begin
						  SR1MUX = 1'b0; // select input address of sr1, which will be lower bits
                    SR2MUX = IR_5; // select mode for sr2mux
                    ALUK = 2'b01; // set alu to and
                    GateALU = 1'b1; // open gate
						  DRMUX = 1'b0; // select address from IR[11:9]
                    LD_REG = 1'b1; // load
						  LD_CC = 1'b1; // setCC
                end
				S_09 : 
                begin 
						  SR1MUX = 1'b0; // select input address of sr1, which will be lower bits
                    ALUK = 2'b10; // set alu to not s1
                    GateALU = 1'b1; // open gate
						  DRMUX = 1'b0; // select address from IR[11:9]
                    LD_REG = 1'b1; // load
						  LD_CC = 1'b1; // setCC
                end
				// LDR Control
				S_06 :
					begin
					SR1MUX = 1'b0; // choose SR1 from IR[8:6]
					ADDR1MUX = 1'b1; // choose sr1 for addr1
					ADDR2MUX = 2'b01; // choose offset 6
					GateMARMUX = 1'b1; // open gate
					LD_MAR = 1'b1; // load into mar
					Mem_OE = 1'b0; // set 1 state early since synchronizer will delay by one clock cycle
					end
				S_25_1 :
					Mem_OE = 1'b0; // read from mem
				S_25_2 :
					begin
					Mem_OE = 1'b0; // read from mem
					LD_MDR = 1'b1; // load mdr
					end
				S_27 :
					begin
					GateMDR = 1'b1;
					DRMUX = 1'b0; // select address from IR[11:9]
					LD_REG = 1'b1;
					LD_CC = 1'b1; // setCC
					end
				// STR Control
				S_07 :
					begin
					SR1MUX = 1'b0; // choose SR1 from IR[8:6]
					ADDR1MUX = 1'b1; // choose sr1 for addr1
					ADDR2MUX = 2'b01; // choose offset 6
					GateMARMUX = 1'b1; // open gate
					LD_MAR = 1'b1; // load into mar
					end
				S_23 :
					begin
					SR1MUX = 1'b1; // choose SR1 from IR[11:9]
					ALUK = 2'b11; // pass output from SR1 through alu
					GateALU = 1'b1; // put sr1 on bus
					LD_MDR = 1'b1; // load mdr
					Mem_WE = 1'b0; // set 1 state early since synchronizer will delay by one clock cycle
					end
				S_16_1 : // write mem for 2 cycles
					Mem_WE = 1'b0;
				S_16_2 :
					Mem_WE = 1'b0;
				
				// BR Control
				// S_00 : No control signals, transistions handled in above transition comb block
				S_22 :
					 begin
					 ADDR1MUX = 1'b0; // choose pc for addr1
					 ADDR2MUX = 2'b10; // choose off9 for addr2
					 PCMUX = 2'b01; // pc input from marmux
					 LD_PC = 1'b1; // load PC
					 end
					 
				// JSR Control
				S_04 :
					 begin
					 GatePC = 1'b1; // open pc gate
					 DRMUX = 1'b1; // choose R7
					 LD_REG = 1'b1; // load reg
					 end
				S_21 :
					 begin
					 ADDR1MUX = 1'b0; // choose pc for addr1
					 ADDR2MUX = 2'b11; // choose off11 for addr2
					 PCMUX = 2'b01; // pc input from marmux
					 LD_PC = 1'b1; // load PC
					 end
					 
				// JMP Control
				S_12 :
					 begin
					 SR1MUX = 1'b0; // choose SR1 from IR[8:6]
					 ALUK = 2'b11; // pass sr1 through
					 GateALU = 1'b1; // open gatealu
					 PCMUX = 2'b10; // choose pc mux input from bus
					 LD_PC = 1'b1; // load pc
					 end
				PauseIR1 : 
					 LD_LED = 1'b1;
            default : ;
        endcase
    end 

     // These should always be active
    assign Mem_CE = 1'b0;
    assign Mem_UB = 1'b0;
    assign Mem_LB = 1'b0;
    
endmodule
