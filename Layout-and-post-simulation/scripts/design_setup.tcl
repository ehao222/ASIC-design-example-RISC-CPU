# Design_setup.tcl
source ../rm_setup/common_setup.tcl
source -echo ../rm_setup/common_setup.tcl
source ../rm_setup/icc_setup.tcl
source -echo ../rm_setup/icc_setup.tcl
source ../rm_setup/lcrm_setup.tcl
source -echo ../rm_setup/lcrm_setup.tcl
# Design Library Creation
  create_mw_lib control_pad.mw -open -tech $TECH_FILE -mw_reference_library $MW_REFERENCE_LIB_DIRS

echo ###########end of creating of the mw lib #################
# Read the Netlist and Create a Design CEL
if {$ICC_INIT_DESIGN_INPUT=="VERILOG"} {
	read_verilog -top $DESIGN_NAME $ICC_INPUTS_PATH/$ICC_IN_VERILOG_NETLIST_FILE 
        current_design $DESIGN_NAME 
        uniquify
        save_mw_cel -as $DESIGN_NAME
}
set_tlu_plus_files -max_tluplus SmicSPM4PR8R_starRCXT013_log_mixRF_p1mt8_cell_max_1233_9k_1f.tluplus -tech2itf_map SmicSPM4PR8R_013_log_mixRF_p1mt8_cell_max_1233_9k_1f.map
###################################
#connect to supply nets
###################################
derive_pg_connection -create_net; #first create P/G nets defined in UPF FILE
derive_pg_connection -power_net VDD -power_pin VDD -ground_net VSS -ground_pin VSS;
# Connect P/G Pins to supply nets,
derive_pg_connection -power_net VDD -ground_net VSS -create_ports top -tie;
check_mv_design
##################################
#Apply and Check Timing Constraints
###################################
read_sdc $ICC_INPUTS_PATH/control_pad.sdc
check_timing
report_timing_requirements
report_disable_timing
report_case_analysis
###################################
#check the clock
##################################
report_clock
report_clock -skew
##################################
#Timing and optimization controls
###################################
source ../scripts/common_optimization_settings_icc.tcl
set_zero_interconnect_delay_mode true
report_constraint -all
report_timing
set_zero_interconnect_delay_mode false
remove_ideal_network [get_ports "rst_ clk"]
##################################
#Save the cel after data setup
#################################
save_mw_cel -as data_setup
