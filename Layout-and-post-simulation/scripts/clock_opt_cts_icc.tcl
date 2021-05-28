##########################################################################################
# Version: G-2012.06 (July 2, 2012)
# Copyright (C) 2007-2012 Synopsys, Inc. All rights reserved.
##########################################################################################
#################################################################################
# Lynx Compatible Setup : Overview
#
# This LCRM script contains support for running standalone or within the Lynx
# Design System without change. Note that Lynx is not required to run standalone.
#
# Features available when running within Lynx Design System include:
#
# * Graphical flow configuration and execution monitoring
# * Tool setup and version management
# * Job distribution handling
# * Visual execution status and error checking
# * Design and System metric capture for analysis in Lynx Manager Cockpit
#################################################################################

#################################################################################
# Lynx Compatible Setup : Task Environment Variables (TEV)
#
# Task Environment Variables allow configuration of this tool script.
# The Lynx Design System will automatically recognize the TEV definitions
# in this script and make them visible for configuration in the Lynx Design
# System graphical user interface.
#################################################################################

## NAME: TEV(num_cores)
## TYPE: integer
## INFO:
## * Specifies the number of cores to be used for multicore optimization.
## * Use a value of 1 to indicate single-core optimization (default).
set TEV(num_cores) 1

#################################################################################
# Lynx Compatible Setup : Script Initialization
#
# This section is used to initialize the scripts for use with the Lynx Design
# System.  Users should not make modifications to this section.
#################################################################################

set SEV(src) place_opt_icc
set SEV(dst) clock_opt_cts_icc

set SEV(script_file) [info script]

source ../../scripts_block/lcrm_setup/lcrm_setup.tcl

sproc_script_start
source -echo ../../scripts_block/rm_setup/icc_setup.tcl 
set ICC_PLACE_OPT_CEL $SEV(src) 
set ICC_CLOCK_OPT_CTS_CEL $SEV(dst) 

###########################################################
## clock_opt_cts_icc: Clock Tree Synthesis and Optimization 
###########################################################

 
open_mw_lib $MW_DESIGN_LIBRARY
redirect /dev/null "remove_mw_cel -version_kept 0 ${ICC_CLOCK_OPT_CTS_CEL}" 
copy_mw_cel -from $ICC_PLACE_OPT_CEL -to $ICC_CLOCK_OPT_CTS_CEL
open_mw_cel $ICC_CLOCK_OPT_CTS_CEL



## Optimization Common Session Options - set in all sessions
source -echo common_optimization_settings_icc.tcl
source -echo common_placement_settings_icc.tcl

## Source CTS Options 
source -echo common_cts_settings_icc.tcl

set_app_var cts_instance_name_prefix CTS

  check_mv_design -verbose
 ## By default, all scenarios are made active here, prior to CTS. This will ensure that all clock related 
 ## attributes ( propagation, set_fix_hold, latency, uncertainty) will be available in each scenario.
 ## If you reduce the active scenarios here, or if you add new scenarios later in the flow
 ## then you will have to manually provide all this info for 
 ## each inactive scenario, after running clock_opt -only_cts
 ## 
 set prects_cur_scenario [current_scenario]
 set prects_active_scenarios [all_active_scenarios]

 set_active_scenarios [all_scenarios]
 ## Detects CTS only scenarios ,sets -setup to true 
 set cts_only_scenarios [get_scenarios -cts_mode true -setup false]
 if {[llength $cts_only_scenarios]} {
   set_scenario_options -cts_mode true -setup true -scenarios $cts_only_scenarios
 }

##############################
## RP : Relative Placement  ##                
##############################
## Ensuring that the RP cells are not changed during clock_opt
#set_rp_group_options [all_rp_groups] -cts_option fixed_placement
#set_rp_group_options [all_rp_groups] -cts_option "size_only"

set_delay_calculation -clock_arnoldi

 set cur_scenario [current_scenario]
 current_scenario [lindex [get_scenarios -cts_mode true] 0]
if {$ICC_SANITY_CHECK} {
        check_physical_design -stage pre_clock_opt -no_display -output $REPORTS_DIR_CLOCK_OPT_CTS/check_physical_design.pre_clock_opt 
}
 current_scenario $cur_scenario 

if {$ICC_ENABLE_CHECKPOINT} {
echo "SCRIPT-Info : Please ensure there's enough disk space before enabling the set_checkpoint_strategy feature."
set_checkpoint_strategy -enable -overwrite
# The -overwrite option is used by default. Remove it if needed.
}

# A SAIF file is optional for self-gating
if {$ICC_CTS_SELF_GATING && [file exists [which $ICC_IN_SAIF_FILE]]} {
  foreach scenario [all_active_scenarios] {
    current_scenario $scenario
    read_saif -input $ICC_IN_SAIF_FILE -instance_name $ICC_SAIF_INSTANCE_NAME
  }
}


if {[file exists [which $CUSTOM_CLOCK_OPT_CTS_PRE_SCRIPT]]} {
source $CUSTOM_CLOCK_OPT_CTS_PRE_SCRIPT
}

set clock_opt_cts_cmd "clock_opt -only_cts -no_clock_route"
if {!$DFT && [get_scan_chain] == 0} {lappend clock_opt_cts_cmd -continue_on_missing_scandef}
if {$ICC_CTS_INTERCLOCK_BALANCING && [file exists [which $ICC_CTS_INTERCLOCK_BALANCING_OPTIONS_FILE]]} {lappend clock_opt_cts_cmd -inter_clock_balance}
if {$ICC_CTS_UPDATE_LATENCY} {lappend clock_opt_cts_cmd -update_clock_latency}
if {$ICC_CTS_SELF_GATING} {lappend clock_opt_cts_cmd -insert_self_gating}
echo $clock_opt_cts_cmd
eval $clock_opt_cts_cmd

if {[file exists [which $CUSTOM_CLOCK_OPT_CTS_POST_SCRIPT]]} {
source $CUSTOM_CLOCK_OPT_CTS_POST_SCRIPT
}

if {$ICC_ENABLE_CHECKPOINT} {set_checkpoint_strategy -disable}

if { [check_error -verbose] != 0} { echo "SCRIPT-Error, flagging ..." }
############################################################################################################
# ADDING ADDITIONAL FEATURES TO THE CLOCK_OPT COMMAND
############################################################################################################

## When you want to do interclock delay balancing, you need to execute the following commands :
#  set_inter_clock_delay_options -balance_group "Clk1 Clk2"
#  clock_opt -inter_clock_balance


## When you want to update the IO latency before you start the post CTS optimization, add :
# set_latency_adjustment_options -from_clock  ....  -to_clock .... -latency ....
# clock_opt -update_clock_latency -no_clock_route


## checking whether the clock nets got the NDR
# report_net_routing_rules [get_nets -hier *]



########################################
#           CONNECT P/G                #
########################################
## Connect Power & Ground for non-MV and MV-mode

 if {[file exists [which $CUSTOM_CONNECT_PG_NETS_SCRIPT]]} {
   source -echo $CUSTOM_CONNECT_PG_NETS_SCRIPT
 } else {
    if {!$ICC_TIE_CELL_FLOW} {derive_pg_connection -verbose -tie}
    redirect -file $REPORTS_DIR_CLOCK_OPT_CTS/clock_opt_cts.mv {check_mv_design -verbose}
   }
if { [check_error -verbose] != 0} { echo "SCRIPT-Error, flagging ..." }

source -echo common_post_cts_timing_settings.tcl
   set cur_active_scenarios [all_active_scenarios]
   set_active_scenarios -all
   foreach scenario [all_active_scenarios] {
     #ideal network
     remove_ideal_network [all_fanout -flat -clock_tree]
     ##If not all scenarios are active at the start of the script, you must propagate clocks manually for each scenario
     # foreach_in_collection clk [get_clocks] {
     #   set_propagated_clock [get_attr $clk sources]
     # }
   }
   set_active_scenarios $cur_active_scenarios

   foreach scenario [all_active_scenarios] {
     current_scenario $scenario
     #set fix hold 
     set_fix_hold [all_clocks]

     #uncertainties 
     if {$ICC_APPLY_RM_UNCERTAINTY_POSTCTS && [file exists [which $ICC_UNCERTAINTY_POSTCTS_FILE.$scenario]] } {
           echo "SCRIPT-Info: Sourcing the post-cts uncertainty file : $ICC_UNCERTAINTY_POSTCTS_FILE.$scenario"
           source -echo $ICC_UNCERTAINTY_POSTCTS_FILE.$scenario
     }
   }

  current_scenario $prects_cur_scenario

if {$ICC_REPORTING_EFFORT != "OFF" } {
     if {[llength [get_scenarios -active true -setup true]]} {
     redirect -file $REPORTS_DIR_CLOCK_OPT_CTS/$ICC_CLOCK_OPT_CTS_CEL.clock_timing {report_clock_timing -nosplit -type skew -scenarios [get_scenarios -active true -setup true]} ;# local skew report
     redirect -tee -file $REPORTS_DIR_CLOCK_OPT_CTS/$ICC_CLOCK_OPT_CTS_CEL.max.clock_tree {report_clock_tree -nosplit -summary -scenarios [get_scenarios -active true -setup true]}     ;# global skew report
     }
     if {[llength [get_scenarios -active true -hold true]]} {
     redirect -tee -file $REPORTS_DIR_CLOCK_OPT_CTS/$ICC_CLOCK_OPT_CTS_CEL.min.clock_tree {report_clock_tree -nosplit -operating_condition min -summary -scenarios [get_scenarios -active true -hold true]}     ;# min global skew report
     }
}

 set_active_scenarios $prects_active_scenarios
 unset prects_active_scenarios
 ## Detects CTS only scenarios ,restores -setup to false 
 if {[info exists cts_only_scenarios]} {
   if {[llength $cts_only_scenarios]} {set_scenario_options -cts_mode true -setup false -scenarios $cts_only_scenarios} 
   unset cts_only_scenarios
 }
if {$ICC_REPORTING_EFFORT == "MED" } {
 redirect -file $REPORTS_DIR_CLOCK_OPT_CTS/$ICC_CLOCK_OPT_CTS_CEL.max.tim {report_timing -nosplit -scenario [all_active_scenarios] -capacitance -transition_time -input_pins -nets -delay max} 
 redirect -file $REPORTS_DIR_CLOCK_OPT_CTS/$ICC_CLOCK_OPT_CTS_CEL.min.tim {report_timing -nosplit -scenario [all_active_scenarios] -capacitance -transition_time -input_pins -nets -delay min} 
}
if {$ICC_REPORTING_EFFORT == "MED" } {
   redirect -tee -file $REPORTS_DIR_CLOCK_OPT_CTS/$ICC_CLOCK_OPT_CTS_CEL.qor {report_qor}
   redirect -tee -file $REPORTS_DIR_CLOCK_OPT_CTS/$ICC_CLOCK_OPT_CTS_CEL.qor -append {report_qor -summary}
   redirect -file $REPORTS_DIR_CLOCK_OPT_CTS/$ICC_CLOCK_OPT_CTS_CEL.con {report_constraints}
}


save_mw_cel -as $ICC_CLOCK_OPT_CTS_CEL

if {$ICC_REPORTING_EFFORT != "OFF" } {
   redirect -file $REPORTS_DIR_CLOCK_OPT_CTS/$ICC_CLOCK_OPT_CTS_CEL.placement_utilization.rpt {report_placement_utilization -verbose}
   create_qor_snapshot -clock_tree -name $ICC_CLOCK_OPT_CTS_CEL
   redirect -file $REPORTS_DIR_CLOCK_OPT_CTS/$ICC_CLOCK_OPT_CTS_CEL.qor_snapshot.rpt {report_qor_snapshot -no_display}
}

## Categorized Timing Report (CTR)
#  Use CTR in the interactive mode to view the results of create_qor_snapshot. 
#  Recommended to be used with GUI opened.
#	query_qor_snapshot -display (or GUI: Timing -> Query QoR Snapshot)
#  query_qor_snapshot condenses the timing report into a cross-referencing table for quick analysis. 
#  It can be used to highlight violating paths and metric in the layout window and timing reports. 
#  CTR also provides special options to focus on top-level and hierarchical timing issues. 
#  When dealing with dirty designs, increasing the number violations per path to 20-30 when generating a snapshot can help 
#  find more issues after each run (create_qor_snapshot -max_paths 20).
#  Specify -type min for hold time violations. 

# Lynx compatible procedure which produces design metrics based on reports
sproc_generate_metrics

# Lynx Compatible procedure which performs final metric processing and exits
sproc_script_stop

