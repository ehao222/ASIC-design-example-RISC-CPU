source ../rm_setup/common_setup.tcl
source -echo ../rm_setup/common_setup.tcl
source ../rm_setup/icc_setup.tcl
source -echo ../rm_setup/icc_setup.tcl
source ../rm_setup/lcrm_setup.tcl
source -echo ../rm_setup/lcrm_setup.tcl
open_mw_lib control_pad.mw
copy_mw_cel -from data_setup -to floorplan
open_mw_cel floorplan
#########################################
#Create a Rectangular Block
########################################
#Create coner cells and supply cells
create_cell {cornerll cornerlr cornerul cornerur} PCORNER
create_cell {vss1left vss1right} PVSS1; #core ground
create_cell {vdd1left vdd1right} PVDD1; #core supply 
create_cell {vss2top vss2bottom} PVSS2; #pad ground
create_cell {vdd2top vdd2bottom} PVDD2;#pad_supply

#constrain the corners
set_pad_physical_constraints -pad_name "cornerul" -side 1
set_pad_physical_constraints -pad_name "cornerur" -side 2
set_pad_physical_constraints -pad_name "cornerlr" -side 3
set_pad_physical_constraints -pad_name "cornerll" -side 4

#Constrin the upper side ports
set_pad_physical_constraints -pad_name "i_opcode_2" -side 2 -order 1
set_pad_physical_constraints -pad_name "i_zero" -side 2 -order 2
set_pad_physical_constraints -pad_name "vdd2top" -side 2 -order 3
set_pad_physical_constraints -pad_name "vss2top" -side 2 -order 4
set_pad_physical_constraints -pad_name "i_ld_pc" -side 2 -order 5
set_pad_physical_constraints -pad_name "i_inc_pc" -side 2 -order 6

#Constrain the right side ports
set_pad_physical_constraints -pad_name "i_rd" -side 3 -order 1
set_pad_physical_constraints -pad_name "i_wr" -side 3 -order 2
set_pad_physical_constraints -pad_name "vdd1right" -side 3 -order 4
set_pad_physical_constraints -pad_name "vss1right" -side 3 -order 3
set_pad_physical_constraints -pad_name "i_ld_ir" -side 3 -order 5
set_pad_physical_constraints -pad_name "i_ld_ac" -side 3 -order 6

#constrain the bottom side ports
set_pad_physical_constraints -pad_name "i_halt" -side 4 -order 1
set_pad_physical_constraints -pad_name "i_data_e" -side 4 -order 2
set_pad_physical_constraints -pad_name "vdd2bottom" -side 4 -order 3
set_pad_physical_constraints -pad_name "vss2bottom" -side 4 -order 4
set_pad_physical_constraints -pad_name "i_sel" -side 4 -order 5
set_pad_physical_constraints -pad_name "i_inc_pc" -side 4 -order 6

#constrain the left side ports
set_pad_physical_constraints -pad_name "i_rst" -side 1 -order 1
set_pad_physical_constraints -pad_name "i_clk" -side 1 -order 2
set_pad_physical_constraints -pad_name "vdd1left" -side 1  -order 3
set_pad_physical_constraints -pad_name "vss1left" -side 1 -order 4
set_pad_physical_constraints -pad_name "i_opcode_0" -side 1 -order 5
set_pad_physical_constraints -pad_name "i_opcode_1" -side 1 -order 6

#Create floorplan 
create_floorplan -control_type aspect_ratio -core_aspect_ratio 1 -core_utilization 0.7 -left_io2core 30 -bottom_io2core 30 -right_io2core 30 -top_io2core 30 -start_first_row
save_mw_cel -as floorplan_io

###################################
#Place pins
###################################
#create_fp_placement -timing
#routing_zrt_global -congestion_map_only_true -exploration true
save_mw_cel -as floorplanprepn

##################################
#Insert Pad Fillers
##################################
insert_pad_filler -cell "PFILL001 PFILL01 PFILL1 PFILL1 PFILL10 PFILL2 PFILL20 PFILL5 PFILL50"

##################################
#Specify Unrouting Layers
##################################
set_ignored_layers -max_routing_layer METAL6
report_ignored_layers

save_mw_cel -as floorplan_prepns

################################
#Create the  Power Network
###############################
###############################
#Performing Power Planning
###############################
#Apply Power  Ring Constraints
create_power_plan_regions core -core
#set_power_ring_strategy core -core -nets {VDD VSS}

set_power_ring_strategy core -core -nets {VDD VSS} -template /home1/lib/icc_dz/IC_Compiler_2012.06/ORCA_TOP/scripts_block/scripts_lu/basic_ring.tpl:basic_ring
#Synthesizing the power network
remove_power_plan_strategy -all
set_power_plan_strategy s_basic_no_va -nets {VDD VSS} -core -extension {{{nets:VDD}{stop:outermost_ring}}{{nets: VSS}{stop:outermost_ring}}} -template ../scripts/pg_mesh.tpl:pg_mesh_top

#Create ring
compile_power_plan -ring

#Create mesh
compile_power_plan
#connect vdd vss  logic "1" and "0"
derive_pg_connection -create_net;
derive_pg_connection -power_net VDD -power_pin VDD -ground_net VSS -ground_net VSS;
derive_pg_connection -power_net VDD -ground_net VSS -tie;
save_mw_cel -as floorplanafterpn

###############################
#Route Standard Cell Rails
###############################
set_preroute_drc_strategy -min_layer METAL3 -max_layer METAL8
preroute_standard_cells -nets "VDD VSS" -remove_floating_pieces -do_not_route_over_macros;

create_fp_placement -congestion -timing -no_hierarchy_gravity
route_zrt_global -congestion_map_only true -exploration true
preroute_instances

#save the design
save_mw_cel -as floorplaned
create_fp_placement -congestion -timing -no_hierarchy_gravity
route_zrt_global -congestion_map_only true -exploration true

preroute_instances
