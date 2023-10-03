
############################  Search PATH ################################

set PROJECT_PATH /home/IC/Labs/SYSTEM/rtl
set LIB_PATH     /home/IC/Labs/SYSTEM/std_cells

lappend search_path $LIB_PATH
lappend search_path $PROJECT_PATH


########################### Define Top Module ############################
                                                   
set top_module SYS_TOP

######################### Formality Setup File ###########################

set synopsys_auto_setup true

set_svf $top_module.svf


####################### Read Reference tech libs ########################
 

set SSLIB "scmetro_tsmc_cl013g_rvt_ss_1p08v_125c.db"
set TTLIB "scmetro_tsmc_cl013g_rvt_tt_1p2v_25c.db"
set FFLIB "scmetro_tsmc_cl013g_rvt_ff_1p32v_m40c.db"

read_db -container Ref [list $SSLIB $TTLIB $FFLIB]

###################  Read Reference Design Files ######################## 
read_verilog -container Ref "ALU.v"
read_verilog -container Ref "bit_syn.v"
read_verilog -container Ref "FIFO_MEM.v"
read_verilog -container Ref "R_CTRL.v"
read_verilog -container Ref "W_CTRL.v"
read_verilog -container Ref "ASYC_FIFO.v"
read_verilog -container Ref "CLKDIV_MUX.v"
read_verilog -container Ref "ClkDiv.v"
read_verilog -container Ref "CLK_GATE.v"
read_verilog -container Ref "data_sync.v"
read_verilog -container Ref "RegFile.v"
read_verilog -container Ref "PULSE_GEN.v"
read_verilog -container Ref "rst_syn.v"
read_verilog -container Ref "SYS_CTRL_badr.v"
read_verilog -container Ref "data_sampling.v"
read_verilog -container Ref "deserializer.v"
read_verilog -container Ref "edge_bit_counter.v"
read_verilog -container Ref "parity_check.v"
read_verilog -container Ref "stop_check.v"
read_verilog -container Ref "start_check.v"
read_verilog -container Ref "UART_RX.v"
read_verilog -container Ref "FSM.v"


read_verilog -container Ref "UART_TX.v"
read_verilog -container Ref "MY_MUX.v"
read_verilog -container Ref "MY_PAR.v"
read_verilog -container Ref "MY_serializer.v"
read_verilog -container Ref "MY_FSM.v"

read_verilog -container Ref "SYS_TOP.v"

######################## set the top Reference Design ######################## 

set_reference_design SYS_TOP
set_top SYS_TOP











####################### Read Implementation tech libs ######################## 

read_db -container Imp [list $SSLIB $TTLIB $FFLIB]

#################### Read Implementation Design Files ######################## 

read_verilog -container Imp -netlist "/home/IC/Labs/SYSTEM/syn/SYS_TOP.v"

####################  set the top Implementation Design ######################

set_implementation_design SYS_TOP
set_top SYS_TOP


## matching Compare points
match

## verify
set successful [verify]
if {!$successful} {
diagnose
analyze_points -failing
}

report_passing_points > "reports/passing_points.rpt"
report_failing_points > "reports/failing_points.rpt"
report_aborted_points > "reports/aborted_points.rpt"
report_unverified_points > "reports/unverified_points.rpt"


start_gui

