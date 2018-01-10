## Generated SDC file "finalproject.sdc"

## Copyright (C) 1991-2015 Altera Corporation. All rights reserved.
## Your use of Altera Corporation's design tools, logic functions 
## and other software and tools, and its AMPP partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Altera Program License 
## Subscription Agreement, the Altera Quartus II License Agreement,
## the Altera MegaCore Function License Agreement, or other 
## applicable license agreement, including, without limitation, 
## that your use is for the sole purpose of programming logic 
## devices manufactured by Altera and sold by Altera or its 
## authorized distributors.  Please refer to the applicable 
## agreement for further details.


## VENDOR  "Altera"
## PROGRAM "Quartus II"
## VERSION "Version 15.0.0 Build 145 04/22/2015 SJ Web Edition"

## DATE    "Fri Dec 01 15:50:06 2017"

##
## DEVICE  "EP4CE115F29C7"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {clk} -period 20.000 -waveform { 0.000 10.000 } [get_ports {CLOCK_50}]


#**************************************************************
# Create Generated Clock
#**************************************************************



#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************



#**************************************************************
# Set Input Delay
#**************************************************************

set_input_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {SRAM_DQ[0]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {SRAM_DQ[1]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {SRAM_DQ[2]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {SRAM_DQ[3]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {SRAM_DQ[4]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {SRAM_DQ[5]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {SRAM_DQ[6]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {SRAM_DQ[7]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {SRAM_DQ[8]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {SRAM_DQ[9]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {SRAM_DQ[10]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {SRAM_DQ[11]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {SRAM_DQ[12]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {SRAM_DQ[13]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {SRAM_DQ[14]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {SRAM_DQ[15]}]


#**************************************************************
# Set Output Delay
#**************************************************************

set_output_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {SRAM_ADDR[0]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {SRAM_ADDR[1]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {SRAM_ADDR[2]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {SRAM_ADDR[3]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {SRAM_ADDR[4]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {SRAM_ADDR[5]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {SRAM_ADDR[6]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {SRAM_ADDR[7]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {SRAM_ADDR[8]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {SRAM_ADDR[9]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {SRAM_ADDR[10]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {SRAM_ADDR[11]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {SRAM_ADDR[12]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {SRAM_ADDR[13]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {SRAM_ADDR[14]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {SRAM_ADDR[15]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {SRAM_ADDR[16]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {SRAM_ADDR[17]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {SRAM_ADDR[18]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {SRAM_ADDR[19]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {SRAM_CE_N}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {SRAM_LB_N}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {SRAM_OE_N}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {SRAM_UB_N}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {SRAM_WE_N}]


#**************************************************************
# Set Clock Groups
#**************************************************************



#**************************************************************
# Set False Path
#**************************************************************



#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************

