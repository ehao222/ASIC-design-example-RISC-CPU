##########################################################################################
# Version: G-2012.06 (July 2, 2012)
# Copyright (C) 2007-2012 Synopsys, Inc. All rights reserved.
##########################################################################################

puts "RM-Info: Running script [info script]\n"

## CTS Common Session Options - set in place_opt and clock_opt sessions

## Clock Tree References
#  Choose Balanced Buffers and Inverters for best results
#  Avoid low strengths for initial CTS (bad CTS)
#  Avoid high strengths for signal EM problems
#  Each of the following list take a space separated list of buffers/cels: ex: "buf1 inv1 inv2"
#  Note: references are cumulative
if {$ICC_CTS_REF_LIST != "" || $ICC_CTS_REF_SIZING_ONLY != "" || $ICC_CTS_REF_DEL_INS_ONLY != ""} {reset_clock_tree_references}
if {$ICC_CTS_REF_LIST != ""} {set_clock_tree_references -references $ICC_CTS_REF_LIST}
if {$ICC_CTS_REF_DEL_INS_ONLY != ""} {set_clock_tree_references -delay_insertion_only -references $ICC_CTS_REF_DEL_INS_ONLY}
if {$ICC_CTS_REF_SIZING_ONLY != ""} {set_clock_tree_references -sizing_only -references $ICC_CTS_REF_SIZING_ONLY}

############
# CLOCK NDR
############
## Define clock NDR prior to CTS such that CTS can predict its effects.
#  Avoid setting NDR rules on metal 1 to avoids pin access issues on buffers and gates in clock trees.
#  Please refer to Create NDR Example 1, 2, and 3 below, specify your NDR name as $ICC_CTS_RULE_NAME in icc_setup.tcl and define it here.
#  Note : if you do not change the value of $ICC_CTS_RULE_NAME from iccrm_clock_double_spacing, 
#  ICC-RM will create a 2x spacing rule for you. See Example1.
#  Your clock NDR here :
#  define_routing_rule $ICC_CTS_RULE_NAME . . .

## Create NDR Example1 : define double spacing NDR (ICC-RM default)
#  If you do not change the value of $ICC_CTS_RULE_NAME, ICC-RM will create a 2x spacing rule for you.
if {$ICC_CTS_RULE_NAME == "iccrm_clock_double_spacing"} {
  redirect -var x {report_routing_rules $ICC_CTS_RULE_NAME}
  ## Automatically create a double spacing NDR if ICC_CTS_RULE_NAME is set to iccrm_clock_double_spacing
  if {[regexp "Info: No nondrule" $x]} {
    define_routing_rule $ICC_CTS_RULE_NAME -default_reference_rule -multiplier_spacing 2
    ## add -multiplier_width 2 for double width
  } 
}

## Create NDR Example2 : define NDR spacings and widths
#  define_routing_rule $ICC_CTS_RULE_NAME \
#  	-default_reference_rule \
#  	-spacings "my_clock_ndr_metal_layer_and_spacing" \
#  	-widths "my_clock_ndr_metal_layer_and_width" \
#  	-spacing_length_thresholds <use 3-5x metal layer pitch>

## Create NDR Example3 : define double via NDR with Zroute 
#  Zroute will insert double via during clock nets routing.
#  If there is no via defined with -via_cuts, for that layer Zroute will use default via with single cut
#  Note: if classic router is used, R & NR syntax do not apply and will be ignored
#  To use 1x2 via34 via-array, and allow rotation and swapping og the via-array :
#  define_routing_rule $ICC_CTS_RULE_NAME \
#	-default_reference_rule \    
#       -via_cuts {{via34 1x2 NR} {via34 2x1 R} {via34 2x1 NR} {via34 1x2 R}}


## If ICC_CTS_RULE_NAME is valid, apply it with "set_clock_tree_options -routing_rule"
if {$ICC_CTS_RULE_NAME != ""} {
  redirect -var x {report_routing_rules $ICC_CTS_RULE_NAME}
  if {![regexp "Info: No nondrule" $x]} {
    report_routing_rules $ICC_CTS_RULE_NAME
    set_clock_tree_options -routing_rule $ICC_CTS_RULE_NAME -use_default_routing_for_sinks 1  ;#apply rule to all but leaf nets
  }
}

#####################
# CLOCK SHIELDING NDR
#####################
## Define clock shielding NDR
if {$ICC_CTS_SHIELD_RULE_NAME != ""} {
  redirect -var x {report_routing_rules $ICC_CTS_SHIELD_RULE_NAME}
  if {[regexp "Info: No nondrule" $x]} {
    define_routing_rule $ICC_CTS_SHIELD_RULE_NAME \
    	-default_reference_rule \
    	-shield_spacings "$ICC_CTS_SHIELD_SPACINGS" \
    	-shield_widths "$ICC_CTS_SHIELD_WIDTHS"
    report_routing_rule $ICC_CTS_SHIELD_RULE_NAME
  }
  if {![regexp "Info: No nondrule" $x] && $ICC_CTS_SHIELD_CLK_NAMES != ""} {
    set_clock_tree_options -routing_rule $ICC_CTS_SHIELD_RULE_NAME -clock_trees $ICC_CTS_SHIELD_CLK_NAMES -use_default_routing_for_sinks 1
  } else {
    set_clock_tree_options -routing_rule $ICC_CTS_SHIELD_RULE_NAME -use_default_routing_for_sinks 1  ;#apply rule to all except leaf nets
  }
}

##Typically route clocks on metal3 and above
if {$ICC_CTS_LAYER_LIST != ""} {set_clock_tree_options -layer_list $ICC_CTS_LAYER_LIST}

## You can use following commands to further specify CTS constraints and options: 
#  set_clock_tree_options -max_tran 	value -clock_trees [list of clocks]
#  set_clock_tree_options -max_cap 	value -clock_trees [list of clocks]
#  set_clock_tree_options -target_skew 	value -clock_trees [list of clocks]
#  Note: it's not recommended to change -max_fanout unless necessary as doing so may degrade QoR easily.

## End of CTS Optimization Session Options #############

puts "RM-Info: Completed script [info script]\n"
