source ../rm_setup/lcrm_setup.tcl
source -echo ../rm_setup/icc_setup.tcl

open_mw_lib control_pad.mw
copy_mw_cel -from cts -to route
open_mw_cel route

########################################
source -echo ../scripts/common_optimization_settings_icc.tcl
source -echo ../scripts/common_placement_settings_icc.tcl
########################################
#Pre-Routing Checks
########################################
check_physical_design -stage pre_route_opt
all_ideal_nets
all_high_fanout -nets -threshold 20
report_preferred_routing_direction
########################################
#Pre-Routing Setup
########################################
derive_pg_connection -power_net VDD -power_pin VDD -ground_net VSS -ground_pin VSS -tie;

########################################
#Route Clock Nets Before Signal Nets
########################################
route_zrt_group -all_clock_nets -reuse_existing_global_route true
########################################
#Route the Signal Nets
########################################
route_opt -initial_route_only
save_mw_cel -as signal_route
########################################
#Perform full post-route optimization
########################################
set_si_options -delta_delay true -static_noise true
route_opt -skip_initial_route -xtalk_reduction -power 
########################################
#Incremental Optimization
########################################

set_fix_hold clk
route_opt -incremental -only_hold_time

save_mw_cel -as routed
set_app_var routeopt_drc_over_timing true
route_opt -effort high -incremental -only_design_rule

########################################
#Check and Fix Physical DRC Violations
########################################
verify_zrt_route;
set_route_zrt_detail_options -repair_shorts_over_macros_effort_level high
route_zrt_detail -incremental true;

save_mw_cel -as route

###############################################
#Write netlist and parasitics
##############################################
source ../rm_setup/lcrm_setup.tcl
source -echo ../rm_setup/icc_setup.tcl
change_names -hierarchy  -rules verilog 
write_verilog -no_physical_only_cells \
              -no_unconnected_cells \
              -no_tap_cells         \
              ../output/control_pad_final.v

extract_rc -coupling_cap
write_parasitics  -output ../output/control_pad.spef \
                  -format SPEF            \
                  -compress              \
                  -no_name_mapping  
