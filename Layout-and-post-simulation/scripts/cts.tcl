
source ../rm_setup/lcrm_setup.tcl
source -echo ../rm_setup/icc_setup.tcl
open_mw_lib control_pad.mw
copy_mw_cel -from place -to cts
open_mw_cel place

#####################################
source -echo ../scripts/common_optimization_settings_icc.tcl
source -echo ../scripts/common_placement_settings_icc.tcl
## Source CTS Options
#source -echo common_cts_settings_icc.tcl
#####################################
#Check The Design Before CTS
#####################################
check_physical_design -stage pre_clock_opt
check_clock_tree

#####################################
#Remove all ideal network setting on clocks
#####################################
remove_ideal_network [get_ports clk]
remove_clock_uncertainty [all_clocks]
#set_delay_calculation_options -routed_clock arnoldi

set_clock_tree_option -target_early_delay 0.9
set_clock_tree_options -target_skew 0.2
report_clock_tree -settings


clock_opt -no_clock_route -only_cts

update_clock_latency
report_clock_tree
report_clock_timing -type skew

set_fix_hold [all_clocks]
clock_opt -no_clock_route -only_psyn
report_clock_tree
report_clock_timing -type skew

set_fix_hold [all_clocks]
route_zrt_group -all_clock_nets -reuse_existing_global_route true
report_clock_tree
report_clock_timing -type skew

save_mw_cel -as cts









