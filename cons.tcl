
####################################################################################
# Constraints
# ----------------------------------------------------------------------------
#
# 0. Design Compiler variables
#
# 1. Master Clock Definitions
#
# 2. Generated Clock Definitions
#
# 3. Clock Uncertainties
#
# 4. Clock Latencies 
#
# 5. Clock Relationships
#
# 6. set input/output delay on ports
#
# 7. Driving cells
#
# 8. Output load

####################################################################################
           #########################################################
                  #### Section 0 : DC Variables ####
           #########################################################
#################################################################################### 

# Prevent assign statements in the generated netlist (must be applied before compile command)
set_fix_multiple_port_nets -all -buffer_constants -feedthroughs

####################################################################################
           #########################################################
                  #### Section 1 : Clock Definition ####
           #########################################################
set CLK_NAME1 REF_CLK
set CLK_NAME2 UART_CLK
set CLK_PER1 10
set CLK_PER2 271.2967987
set CLK_PER_TX [expr $CLK_PER2 * 32]
set CLK_PER_RX [expr $CLK_PER2 * 1] 
set CLK_SETUP_SKEW 0.2
set CLK_HOLD_SKEW 0.1
set CLK_LAT 0
set CLK_RISE 0.1
set CLK_FALL 0.1
#################################################################################### 
# 1. Master Clock Definitions
create_clock -name $CLK_NAME1 -period $CLK_PER1 -waveform "0 [expr $CLK_PER1/2]" [get_ports REF_CLK]
create_clock -name $CLK_NAME2 -period $CLK_PER2 -waveform "0 [expr $CLK_PER2/2]" [get_ports UART_CLK] 
# 2. Generated Clock Definitions
create_generated_clock -master_clock $CLK_NAME1 -source [get_ports REF_CLK] \
                       -name "ALU_CLK" [get_port U0_CLK_GATE/GATED_CLK] \
                       -divide_by 1

create_generated_clock -master_clock $CLK_NAME2 -source [get_ports UART_CLK] \
                       -name "TX_CLK" [get_port U0_ClkDiv_TX/o_div_clk] \
                       -divide_by 32

create_generated_clock -master_clock $CLK_NAME2 -source [get_ports UART_CLK] \
                       -name "RX_CLK" [get_port U1_ClkDiv_RX/o_div_clk] \
                       -divide_by 1
# 3. Clock Latencies
set_clock_latency $CLK_LAT [get_clocks $CLK_NAME1]
set_clock_latency $CLK_LAT [get_clocks $CLK_NAME2]
set_clock_latency $CLK_LAT [get_clocks ALU_CLK]
set_clock_latency $CLK_LAT [get_clocks TX_CLK]
set_clock_latency $CLK_LAT [get_clocks RX_CLK]

# 4. Clock Uncertainties
set_clock_uncertainty -setup $CLK_SETUP_SKEW [get_clocks $CLK_NAME1]
set_clock_uncertainty -hold $CLK_HOLD_SKEW  [get_clocks $CLK_NAME1]

set_clock_uncertainty -setup $CLK_SETUP_SKEW [get_clocks $CLK_NAME2]
set_clock_uncertainty -hold $CLK_HOLD_SKEW  [get_clocks $CLK_NAME2]

set_clock_uncertainty -setup $CLK_SETUP_SKEW [get_clocks ALU_CLK]
set_clock_uncertainty -hold $CLK_HOLD_SKEW  [get_clocks ALU_CLK]

set_clock_uncertainty -setup $CLK_SETUP_SKEW [get_clocks TX_CLK]
set_clock_uncertainty -hold $CLK_HOLD_SKEW  [get_clocks TX_CLK]

set_clock_uncertainty -setup $CLK_SETUP_SKEW [get_clocks RX_CLK]
set_clock_uncertainty -hold $CLK_HOLD_SKEW  [get_clocks RX_CLK]

# 4. Clock Transitions

####################################################################################
set_clock_transition -rise $CLK_RISE  [get_clocks $CLK_NAME1]
set_clock_transition -fall $CLK_FALL  [get_clocks $CLK_NAME1]

set_clock_transition -rise $CLK_RISE  [get_clocks $CLK_NAME2]
set_clock_transition -fall $CLK_FALL  [get_clocks $CLK_NAME2]

set_clock_transition -rise $CLK_RISE  [get_clocks ALU_CLK]
set_clock_transition -fall $CLK_FALL  [get_clocks ALU_CLK]

set_clock_transition -rise $CLK_RISE  [get_clocks TX_CLK]
set_clock_transition -fall $CLK_FALL  [get_clocks TX_CLK]

set_clock_transition -rise $CLK_RISE  [get_clocks RX_CLK]
set_clock_transition -fall $CLK_FALL  [get_clocks RX_CLK]


set_dont_touch_network {REF_CLK RST UART_CLK}

####################################################################################
           #########################################################
             #### Section 2 : Clocks Relationship ####
           #########################################################
####################################################################################
set_clock_groups -asynchronous -group [get_clocks "$CLK_NAME2 TX_CLK RX_CLK"] -group [get_clocks "ALU_CLK $CLK_NAME1"] 

  

####################################################################################
           #########################################################
             #### Section 3 : set input/output delay on ports ####
           #########################################################
####################################################################################
#Constrain Input Paths
set in_delay  [expr 0.2*$CLK_PER_RX]

set_input_delay $in_delay -clock RX_CLK [get_port UART_RX_IN]


#Constrain Output Paths

set out_delay [expr 0.2*$CLK_PER_TX]

set_output_delay $out_delay -clock TX_CLK [get_port UART_TX_O]


set out_delay [expr 0.2*$CLK_PER_RX]

set_output_delay $out_delay -clock RX_CLK [get_port parity_error]


set out_delay [expr 0.2*$CLK_PER_RX]

set_output_delay $out_delay -clock RX_CLK [get_port framing_error]


####################################################################################
           #########################################################
                  #### Section 4 : Driving cells ####
           #########################################################
####################################################################################
set_driving_cell -library scmetro_tsmc_cl013g_rvt_ss_1p08v_125c -lib_cell BUFX2M -pin Y [get_port UART_RX_IN]

####################################################################################
           #########################################################
                  #### Section 5 : Output load ####
           #########################################################
####################################################################################

set_load 0.5 [get_port UART_TX_O]

set_load 0.5 [get_port parity_error]

set_load 0.5 [get_port framing_error]

####################################################################################
           #########################################################
                 #### Section 6 : Operating Condition ####
           #########################################################
####################################################################################

# Define the Worst Library for Max(#setup) analysis
# Define the Best Library for Min(hold) analysis

set_operating_conditions -min_library "scmetro_tsmc_cl013g_rvt_ff_1p32v_m40c" -min "scmetro_tsmc_cl013g_rvt_ff_1p32v_m40c" -max_library "scmetro_tsmc_cl013g_rvt_ss_1p08v_125c" -max "scmetro_tsmc_cl013g_rvt_ss_1p08v_125c"

####################################################################################
           #########################################################
                  #### Section 7 : wireload Model ####
           #########################################################
####################################################################################

#set_wire_load_model -name tsmc13_wl30 -library scmetro_tsmc_cl013g_rvt_ss_1p08v_125c

####################################################################################


