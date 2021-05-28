
source  ../rm_setup/lcrm_setup.tcl
source  -echo ../rm_setup/icc_setup.tcl

open_mw_lib control_pad.mw
copy_mw_cel -from floorplaned -to place
open_mw_cel place

##########################################
source -echo ../scripts/common_optimization_settings_icc.tcl
source -echo ../scripts/common_placement_settings_icc.tcl
##########################################

check_physical_design -stage pre_place_opt#This  command  checks the readiness of the current design for IC Compiler.
#@1note:"the pre_place_opt" requires that the floorplan and netlist data are ready and the design constraints are set.
set_ideal_network [all_fanout -flat -clock_tree]
place_opt -area_recovery -congestion
psynopt -area_recovery -congestion#incremental optimization
refine_placement -congestion_effort high
psynopt -area_recovery -congestion

create_qor_snapshot -name placed
query_qor_snapshot -name placed
save_mw_cel -as placed


