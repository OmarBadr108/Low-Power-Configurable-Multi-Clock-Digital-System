
########################### Define Top Module ############################
                                                   
set top_module SYS_TOP

##################### Define Working Library Directory ######################
                                                   
define_design_lib work -path ./work

############################# Formality Setup File ##########################
#set synopsys_auto_setup true
                                                   
set_svf $top_module.svf



################## Design Compiler Library Files #setup ######################

puts "###########################################"
puts "#      #setting Design Libraries          #"
puts "###########################################"

#Add the path of the libraries and RTL files to the search_path variable

set PROJECT_PATH /home/IC/Labs/SYSTEM/rtl
set LIB_PATH     /home/IC/Labs/SYSTEM/std_cells

lappend search_path $LIB_PATH
lappend search_path $PROJECT_PATH

#lappend search_path $PROJECT_PATH/RTL/ASYNC_FIFO
#lappend search_path $PROJECT_PATH/RTL/Clock_Divider
#lappend search_path $PROJECT_PATH/RTL/Clock_Gating
#lappend search_path $PROJECT_PATH/RTL/DATA_SYNC
#lappend search_path $PROJECT_PATH/RTL/RegFile
#lappend search_path $PROJECT_PATH/RTL/PULSE_GEN
#lappend search_path $PROJECT_PATH/RTL/RST_SYNC
#lappend search_path $PROJECT_PATH/RTL/SYS_CTRL
#lappend search_path $PROJECT_PATH/RTL/CLKDIV_MUX
#lappend search_path $PROJECT_PATH/RTL/UART/UART_RX
#lappend search_path $PROJECT_PATH/RTL/UART/UART_TX
#lappend search_path $PROJECT_PATH/RTL/UART/UART_TOP
#lappend search_path $PROJECT_PATH/RTL/Top

set SSLIB "scmetro_tsmc_cl013g_rvt_ss_1p08v_125c.db"
set TTLIB "scmetro_tsmc_cl013g_rvt_tt_1p2v_25c.db"
set FFLIB "scmetro_tsmc_cl013g_rvt_ff_1p32v_m40c.db"

## Standard Cell libraries 
set target_library [list $SSLIB $TTLIB $FFLIB]

## Standard Cell & Hard Macros libraries 
set link_library [list * $SSLIB $TTLIB $FFLIB]  

######################## Reading RTL Files #################################

puts "###########################################"
puts "#             Reading RTL Files           #"
puts "###########################################"

set file_format verilog

#ALU
analyze -format $file_format ALU.v
#FIFO
analyze -format $file_format bit_syn.v
analyze -format $file_format FIFO_MEM.v
analyze -format $file_format R_CTRL.v
analyze -format $file_format W_CTRL.v
analyze -format $file_format ASYC_FIFO.v
#CLK_DIVIDER MUX
analyze -format $file_format CLKDIV_MUX.v
#CLK_DIVIDER
analyze -format $file_format ClkDiv.v
#CLK_GATING
analyze -format $file_format CLK_GATE.v
#DATA_SYNC
analyze -format $file_format data_sync.v
#REGISTER_FILE
analyze -format $file_format RegFile.v
#PULSE_GENERATOR
analyze -format $file_format PULSE_GEN.v
#RST_SYNC
analyze -format $file_format rst_syn.v
#SYS_CONTROLLER
analyze -format $file_format SYS_CTRL_badr.v
#UART_RX
analyze -format $file_format data_sampling.v
analyze -format $file_format deserializer.v
analyze -format $file_format edge_bit_counter.v
analyze -format $file_format parity_check.v
analyze -format $file_format stop_check.v
analyze -format $file_format start_check.v
analyze -format $file_format UART_RX.v
analyze -format $file_format FSM.v
#UART_TX
analyze -format $file_format MY_MUX.v
analyze -format $file_format MY_PAR.v
analyze -format $file_format MY_serializer.v
analyze -format $file_format UART_TX.v
analyze -format $file_format MY_FSM.v
#UART_TOP
#analyze -format $file_format UART.v
#SYS_TOP
analyze -format $file_format SYS_TOP.v

elaborate -lib WORK SYS_TOP

###################### Defining toplevel ###################################

current_design $top_module

#################### Liniking All The Design Parts #########################
puts "###############################################"
puts "######## Liniking All The Design Parts ########"
puts "###############################################"

link 

#################### Liniking All The Design Parts #########################
puts "###############################################"
puts "######## checking design consistency ##########"
puts "###############################################"

check_design >> check_design.rpt

#################### Define Design Constraints #########################
puts "###############################################"
puts "############ Design Constraints #### ##########"
puts "###############################################"

source -echo ./cons.tcl

###################### Mapping and optimization ########################
puts "###############################################"
puts "########## Mapping & Optimization #############"
puts "###############################################"

compile 

##################### Close Formality Setup file ###########################

set_svf -off

#############################################################################
# Write out files
#############################################################################

write_file -format verilog -hierarchy -output $top_module.ddc
write_file -format verilog -hierarchy -output $top_module.v
write_sdf  $top_module.sdf
write_sdc  -nosplit $top_module.sdc

####################### reporting ##########################################

report_area -hierarchy > area.rpt
report_power -hierarchy > power.rpt
report_timing -delay_type min -max_paths 20 > hold.rpt
report_timing -delay_type max -max_paths 20 > setup.rpt
report_clock -attributes > clocks.rpt
report_timing -attributes
report_constraint -all_violators -nosplit > constraints.rpt

############################################################################
# DFT Preparation Section
############################################################################

set flops_per_chain 100

set num_flops [sizeof_collection [all_registers -edge_triggered]]

set num_chains [expr $num_flops / $flops_per_chain + 1 ]

################# starting graphical user interface #######################

#gui_start

#exit
