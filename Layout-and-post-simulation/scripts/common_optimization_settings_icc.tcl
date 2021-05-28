puts "RM-Info: Running script [info script]\n"

##########################################################################################
# Version: G-2012.06 (July 2, 2012)
# Copyright (C) 2007-2012 Synopsys, Inc. All rights reserved.
##########################################################################################

## Optimization Common Session Options - set in all sessions

set_host_options -max_cores $ICC_NUM_CORES

## General Optimization
set_app_var timing_enable_multiple_clocks_per_reg true 
set_fix_multiple_port_nets -all -buffer_constants  
if {$ICC_TIE_CELL_FLOW} {
	set_auto_disable_drc_nets -constant false
} else {
	set_auto_disable_drc_nets -constant true
} 
##Evaluate whether you library and design requires timing_use_enhanced_capacitance_modeling or not. Also only needed for OCV
set_app_var timing_use_enhanced_capacitance_modeling true ;#PT default -  libraries with capacitance ranges (also see Solvnet 021686)
set_app_var enable_recovery_removal_arcs true

   if {$ICC_MAX_AREA != ""} {
     set_max_area $ICC_MAX_AREA
   }


## Set Area Critical Range
## Typical value: 10 percent of critical clock period
if {$AREA_CRITICAL_RANGE_PRE_CTS != ""} {set_app_var physopt_area_critical_range $AREA_CRITICAL_RANGE_PRE_CTS} 


## Set Power Critical Range
## Typical value: 9 percent of critical clock period
if {$POWER_CRITICAL_RANGE_PRE_CTS != ""} {set_app_var physopt_power_critical_range $POWER_CRITICAL_RANGE_PRE_CTS} 


## Set dont use cells
## Examples, big drivers (EM issues), very weak drivers, delay cells, 
## clock cells

if {[file exists [which $ICC_IN_DONT_USE_FILE]] } { 
        source -echo  $ICC_IN_DONT_USE_FILE 
} 


## Fixing the locations of the hard macros
if {[all_macro_cells] != "" } { 
  set_dont_touch_placement [all_macro_cells]  
} 


## Script for customized set_multi_vth_constraints constraints. Effective only when $POWER_OPTIMIZATION is set to TRUE.
#  Specify to make leakage power optimization focused on lvt cell reduction. Refer to rm_icc_scripts/multi_vth_constraint.example as an example.
if {[file exists [which $ICC_CUSTOM_MULTI_VTH_CONSTRAINT_SCRIPT]] } { 
        source -echo  $ICC_CUSTOM_MULTI_VTH_CONSTRAINT_SCRIPT 
}

## End of Common Optimization Session Options

puts "RM-Info: Completed script [info script]\n"
