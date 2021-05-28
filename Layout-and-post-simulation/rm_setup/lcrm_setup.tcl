#########################################################################################
# Lynx Compatible Reference Methodology (LCRM) Setup File
# Script: lcrm_setup.tcl
# Version: G-2012.06 (July 2, 2012)
# Copyright (C) 2011-2012 Synopsys, Inc. All rights reserved.
#########################################################################################
## DESCRIPTION:
## * This script provides LCRM scripts access to a subset of Lynx functions.
## * It manages variables and metric procedures used by the LCRM scripts when
## * running standalone or within the Lynx Design System.
## * 
## * Automation Variables:
## * The LCRM scripts utilize some variables for managing directory structures used
## * for log files, reports, and output data. These variables are hardcoded for correct
## * operation when running LCRM scripts standalone. When running the LCRM scripts within
## * the Lynx Design System, these variables are under control of the flow automation.
## * 
## * Metrics:
## * The lcrm_setup.tcl contains procedures to support extraction of metric information
## * about the design and system. These appear as METRIC strings in the log file. When
## * running within the Lynx Design System, these METRIC messages are extracted and 
## * transfered to a database server. The Lynx Manager Cockpit application can be used
## * to analyze and generate reports from the collected data.
## * 
## * Users of LCRM scripts need not modify any of the contents of this script or
## * related references contained in each task script. These Lynx Compatabile functions
## * work when in Lynx and when running standalone and do not add any appreciable runtime
## * overhead.
## -----------------------------------------------------------------------------


## -----------------------------------------------------------------------------
## Lynx System Variable. 
## When running in Lynx, these SEV* variables are configured in the GUI and saved
## in the system.tcl file. When running outside of Lynx, a number of SEV(*) variables 
## need to be set to values to avoid errors in some of the metric procedures.
## The environment variable LYNX_RTL_PRESENT is set automatically when Lynx is run and
## is used here to setup variables according to the runtime environment
## -----------------------------------------------------------------------------

set SEV(src) init_design_icc
set SEV(dst) init_design_icc

set SEV(script_file) [info script]

#sproc_script_start
set ICC_FLOORPLAN_CEL $SEV(dst) 

#####################################################33

## enable consistent script error handling across tools
set sh_continue_on_error true

## not all tool tcl shells handle the source options. StarRCXT is one example needing special handling
if {[info exists synopsys_program_name]} {
  if { $synopsys_program_name=="tcl" } {
    set source_options ""
  } else {
    set source_options "-e -v"
  }
} else {
  # tcl program does not support -e -v options
  set source_options ""
}

if { [info exists env(LYNX_RTM_PRESENT)] } {

  puts "RM-Info: Lynx is setting SEV variables."
  set LYNX(rtm_present) 1

  eval source $source_options ../../scripts_global/conf/system.tcl

  ## -----------------------------------------------------------------------------
  ## Allow Lynx to define and overide dynamic System Environment Variabls
  ## -----------------------------------------------------------------------------

  eval source $source_options $env(LYNX_VARFILE_SEV)

} else {

  set LYNX(rtm_present) 0
  puts "RM-Info: Setting default SEV variables for running outside of Lynx."
  set SEV(project_dir)    my_project_dir
  set SEV(project_name)   lcrm
  set SEV(release_dir)    my_release_dir
  set SEV(techlib_dir)    my_techlib_dir
  set SEV(metrics_enable) 1
  set SEV(log_file)       my_log_file
  set SEV(ver_star)       NaM
  set SEV(task)           [file root [file tail $SEV(script_file)]]

}


## Remaining SEVs are calculated the same whether running standalone or in Lynx

if { ![info exist SEV(dont_run)] }      { set SEV(dont_run) 0 }
if { ![info exist SEV(dont_exit)] }     { set SEV(dont_exit) 0 }
if { ![info exist SEV(analysis_task)] } { set SEV(analysis_task) 0 }

set SEV(tmp_dir) [pwd]

set SEV(workarea_dir)   [file dirname [file dirname [file dirname [file dirname [file dirname $SEV(tmp_dir)]]]]]
set SEV(techlib_name)   [file tail  [file dirname [file dirname [file dirname $SEV(tmp_dir)]]]]

set SEV(block_dir)      [file dirname [file dirname $SEV(tmp_dir)]]
set SEV(block_name)     [file tail $SEV(block_dir)]
set SEV(step_dir)       [file dirname $SEV(tmp_dir)]
set SEV(step)           [file tail $SEV(step_dir)]
set SEV(gscript_dir)    [file normalize $SEV(tmp_dir)/../../scripts_global]
set SEV(tscript_dir)    [file normalize $SEV(tmp_dir)/../../scripts_global/$SEV(techlib_name)]
set SEV(bscript_dir)    [file normalize $SEV(tmp_dir)/../../scripts_block]
set SEV(work_dir)       [file normalize $SEV(tmp_dir)/../work]
set SEV(src_dir)        [file normalize $SEV(tmp_dir)/../work/$SEV(src)]
set SEV(dst_dir)        [file normalize $SEV(tmp_dir)/../work/$SEV(dst)]
set SEV(log_dir)        [file normalize $SEV(tmp_dir)/../logs/$SEV(dst)]
set SEV(rpt_dir)        [file normalize $SEV(tmp_dir)/../rpts/$SEV(dst)]

## -----------------------------------------------------------------------------
## The SVAR(design_name) must be undefined at this point in the script
## -----------------------------------------------------------------------------

set SVAR(design_name)  undefined

## -----------------------------------------------------------------------------
## These SVAR(tag#) variables are a mechanism for grouping metrics. They are
## not used by default but can be overridden in blck.tcl as shown below
## -----------------------------------------------------------------------------

set SVAR(tag01) [list name value]
set SVAR(tag02) [list name value]
set SVAR(tag03) [list name value]
set SVAR(tag04) [list name value]
set SVAR(tag05) [list name value]
set SVAR(tag06) [list name value]
set SVAR(tag07) [list name value]
set SVAR(tag08) [list name value]
set SVAR(tag09) [list name value]
set SVAR(tag10) [list name value]

## -----------------------------------------------------------------------------
## The block.tcl file is normally empty but sourced here 
## The most common use would be for overriding metric tags SVAR(tag#) listed above
## -----------------------------------------------------------------------------

if {[file exists ../../scripts_block/conf/block.tcl]} {
  puts "RM-Info: sourcing ../../scripts_block/conf/block.tcl"
  eval source $source_options ../../scripts_block/conf/block.tcl
}

if { [info exists env(LYNX_RTM_PRESENT)] } {

  if { ![info exists SVAR(misc,early_complete_enable)] } { set SVAR(misc,early_complete_enable) 0 }

  ## -----------------------------------------------------------------------------
  ## Allow Lynx to overide Task Environment Variabls
  ## -----------------------------------------------------------------------------

  puts "RM-Info: Lynx is setting any TEV overrides from the RTM environment"
  eval source $source_options $env(LYNX_VARFILE_TEV)

} else {
  ## disable early_complete feature for all standalone execution
  set SVAR(misc,early_complete_enable) 0
}

## -----------------------------------------------------------------------------
## These Task variables that need to be assigned for proper standalone behavior but
## that are controlled in the Lynx environment by the content of LYNX_VARFILE_TEV file
## sourced below
## -----------------------------------------------------------------------------

set TEV(vx_enable) 0
set TEV(scenario) DEFAULT_SCENARIO
set TEV(report_level) NORMAL

## -----------------------------------------------------------------------------
## These procedures/variables are not uniformly available
## for all tools used in the flow. This section of code creates
## the procedures/variables if they are not available.
## -----------------------------------------------------------------------------

if { ![info exists synopsys_root] } {
set synopsys_root "synopsys_root"
}

if { ![info exists synopsys_program_name] } {
set synopsys_program_name "tcl"
}

if { $synopsys_program_name == "tcl" } {
set sh_product_version [info patchlevel]
}

if { [info command parse_proc_arguments] != "parse_proc_arguments" } {
proc parse_proc_arguments { cmdSwitch procArgs optsRef } {
upvar $optsRef opts
if { $cmdSwitch == "-args" } {
foreach arg $procArgs {
if { [string index $arg 0] == "-" } {
  set curArg $arg
  set opts($curArg) 1
} else {
  if { [info exists curArg] } {
    set opts($curArg) $arg
    unset curArg
  } else {
    puts "SNPS_ERROR: Found invalid argument: '$arg', with no preceding switch."
    puts "SNPS_ERROR: Called from procedure: [lindex [info level -1] 0]"
  }
}
}
}
}
}

if { [info command define_proc_attributes] != "define_proc_attributes" } {
proc define_proc_attributes args {}
}

if { [info command date] != "date" } {
proc date {} {
return [clock format [clock seconds] -format {%a %b %e %H:%M:%S %Y}]
}
}

## -----------------------------------------------------------------------------
## sproc_script_stop: LCRM customized version
## -----------------------------------------------------------------------------

proc sproc_script_stop { args } {

  global LYNX
  global env SEV SVAR TEV
  global sh_product_version
  global synopsys_program_name

  set options(-exit) 0
  parse_proc_arguments -args $args options

  if {[info exists ::DESIGN_NAME]} {
    ## LCRM generates the corrected SYS.BLOCK metric reflecting DESIGN_NAME
    sproc_msg -info "METRIC | STRING SYS.BLOCK          | $::DESIGN_NAME"
  }

  ## -------------------------------------
  ## Generate metrics for each of the TEV variables.
  ## -------------------------------------

  set generate_metrics_for_tev 0

  if { $generate_metrics_for_tev } {

    set name_list [lsort [array names TEV]]
    foreach name $name_list {
      set length [llength $TEV($name)]
      if { $length == 0 } {
        sproc_msg -info "METRIC | STRING TEV.$name | NULL_VALUE"
      } else {
        sproc_msg -info "METRIC | STRING TEV.$name | $TEV($name)"
      }
    }

  }

  ## -------------------------------------
  ## Generate end-of-script metrics.
  ## -------------------------------------

  sproc_metric_time -stop
  sproc_metric_system -end_of_script

  ## -------------------------------------
  ## Exit processing.
  ## -------------------------------------

  if { $LYNX(rtm_present) } {
    if { $SEV(dont_exit) } {
      ## User is requesting that no exit be performed.
    } else {
      ## Check to see if explicit exit is being requested.
      if { $options(-exit) } {
        if { $synopsys_program_name == "cdesigner" } {
          exit -force 1
        } else {
          exit
        }
      }
    }
  } else {
    if { $synopsys_program_name == "cdesigner" } {
      exit -force 1
    } else {
      exit
    }
  }

}

define_proc_attributes sproc_script_stop \
  -info "Standard procedure for ending a script." \
  -define_args {
  {-exit  "Perform an exit." "" boolean optional}
}

## -----------------------------------------------------------------------------
## sproc_generate_metrics:
## -----------------------------------------------------------------------------

proc sproc_generate_metrics {} {

sproc_pinfo -mode start

global env SEV SVAR TEV
  global synopsys_program_name
  global power_enable_analysis
  global case_analysis_sequential_propagation
  global DESIGN_NAME

  file mkdir $SEV(rpt_dir)

  switch $synopsys_program_name {
    de_shell -
    dc_shell {
      source ../../scripts_block/lcrm_setup/metric_reports_dc.tcl
      sproc_metric_design
      sproc_metric_sta
      sproc_metric_power
    }
    icc_shell {
      source ../../scripts_block/lcrm_setup/metric_reports_icc.tcl
      sproc_metric_design
      sproc_metric_sta
      sproc_metric_power
    }
    pt_shell {
      set RPT(basename) $SEV(rpt_dir)/pt.$TEV(scenario)
      source ../../scripts_block/lcrm_setup/metric_reports_pt.tcl
      sproc_metric_sta
      if { $power_enable_analysis } {
        sproc_metric_power
      }
    }
    tmax_tcl {
      sproc_metric_atpg
    }
  }

  sproc_pinfo -mode stop

}

## -----------------------------------------------------------------------------
## sproc_script_start:
## -----------------------------------------------------------------------------

proc sproc_script_start {} {

  global LYNX
  global env SEV SVAR TEV
  global sh_product_version
  global synopsys_program_name

  sproc_metric_time -start
  sproc_metric_system -start_of_script

}

define_proc_attributes sproc_script_start \
  -info "Standard procedure for starting a script." \
  -define_args {
}

## -----------------------------------------------------------------------------
## sproc_msg:
## -----------------------------------------------------------------------------

proc sproc_msg { args } {

  ## Assigning default value of "bell" since that is never used.

  set options(-info)    "\b"
  set options(-warning) "\b"
  set options(-error)   "\b"
  set options(-setup)   "\b"
  set options(-issue)   "\b"
  set options(-header)  0
  parse_proc_arguments -args $args options

  if       { $options(-info)   != "\b" } {
    puts "SNPS_INFO   : $options(-info)"
  } elseif { $options(-warning) != "\b" } {
    puts "SNPS_WARNING: $options(-warning)"
  } elseif { $options(-error)  != "\b" } {
    puts "SNPS_ERROR  : $options(-error)"
  } elseif { $options(-setup)  != "\b" } {
    puts "SNPS_SETUP  : $options(-setup)"
  } elseif { $options(-issue)  != "\b" } {
    puts "SNPS_ISSUE  : $options(-issue)"
  } elseif { $options(-header) } {
    puts "SNPS_HEADER : ## ------------------------------------- "
  } else {
    puts "SNPS_ERROR  : Unrecognized arguments for sproc_msg : $args"
  }
}

define_proc_attributes sproc_msg \
  -info "Standard message printing procedure." \
  -define_args {
  {-info    "Info message"    AString string optional}
  {-warning "Warning message" AString string optional}
  {-error   "Error message"   AString string optional}
  {-setup   "Setup message"   AString string optional}
  {-issue   "Issue message"   AString string optional}
  {-header  "Header flag"     ""      boolean optional}
}

## -----------------------------------------------------------------------------
## sproc_pinfo:
## -----------------------------------------------------------------------------

proc sproc_pinfo { args } {

  set options(-mode) ""
  parse_proc_arguments -args $args options

  set parent_level [expr [info level] - 1]
  set parent_name [lindex [info level $parent_level] 0]
  set parent_name [regsub {^::} $parent_name {}]

  switch $options(-mode) {
    start   { sproc_msg -info "PROC_START : $parent_name" }
    stop    { sproc_msg -info "PROC_STOP  : $parent_name" }
    default { sproc_msg -error "Invalid argument to sproc_pinfo" }
  }
}

define_proc_attributes sproc_pinfo \
  -info "Prints standard messages at procedure boundaries." \
  -define_args {
  {-mode "Specifies which message to print" AnOos one_of_string
    {required value_help {values {start stop}}}
  }
}

## -----------------------------------------------------------------------------
## sproc_script_version:
## -----------------------------------------------------------------------------

proc sproc_script_version {} {

  sproc_pinfo -mode start

  global LYNX
  global env SEV SVAR TEV

  ## Determine version of $SEV(script_file)

  set version "Nam"

  if { [file exists $SEV(script_file)] } {

    set fid [open $SEV(script_file) r]

    while { [gets $fid line] >= 0 } {

      ## -------------------------------------
      ## Perforce format example:
      ## -------------------------------------

      set re {^## HEADER \$Id: [\w\/\.]+#([\d]+)}

      if { [regexp $re $line match version] } {
        break
      }

      ## -------------------------------------
      ## CVS format example:
      ## -------------------------------------

      set re {^## HEADER \$Id: [\w\/\.\,]+\s+([\d\.]+)}

      if { [regexp $re $line match version] } {
        break
      }

    }

    close $fid
  }

  sproc_pinfo -mode stop
  return $version

}

define_proc_attributes sproc_script_version \
  -info "Used to determine the version of a script." \
  -define_args {
}

## -----------------------------------------------------------------------------
## sproc_metric_system:
## -----------------------------------------------------------------------------

proc sproc_metric_system { args } {

  sproc_pinfo -mode start

  global env SEV SVAR TEV
  global sh_product_version
  global synopsys_program_name

  set xxx1 [clock seconds]

  set options(-start_of_script) 0
  set options(-end_of_script) 0
  parse_proc_arguments -args $args options

  if { $options(-start_of_script) } {

    sproc_msg -info "METRIC | STRING SYS.TASK           | $SEV(task)"
    sproc_msg -info "METRIC | STRING SYS.PROJECT_NAME   | $SEV(project_name)"
    sproc_msg -info "METRIC | STRING SYS.PROJECT_DIR    | $SEV(project_dir)"
    sproc_msg -info "METRIC | STRING SYS.TECHLIB_NAME   | $SEV(techlib_name)"
    sproc_msg -info "METRIC | STRING SYS.TECHLIB_DIR    | $SEV(techlib_dir)"
    sproc_msg -info "METRIC | STRING SYS.WORKAREA_DIR   | $SEV(workarea_dir)"
    sproc_msg -info "METRIC | STRING SYS.BLOCK_DIR      | $SEV(block_dir)"
    sproc_msg -info "METRIC | STRING SYS.USER           | [exec whoami]"
    sproc_msg -info "METRIC | STRING SYS.BLOCK          | $SVAR(design_name)"
    sproc_msg -info "METRIC | STRING SYS.STEP           | $SEV(step)"
    sproc_msg -info "METRIC | STRING SYS.SRC            | $SEV(src)"
    sproc_msg -info "METRIC | STRING SYS.DST            | $SEV(dst)"
    sproc_msg -info "METRIC | STRING SYS.LOG            | [file normalize $SEV(log_file)]"
    sproc_msg -info "METRIC | STRING SYS.SCRIPT_NAME    | [file normalize $SEV(script_file)]"
    sproc_msg -info "METRIC | STRING SYS.SCRIPT_VERSION | [sproc_script_version]"

    set script_type unknown
    if { [regexp "/scripts_global/" $SEV(script_file)] } {
      set script_type global
    }
    if { [regexp "/scripts_global/$SEV(techlib_name)/" $SEV(script_file)] } {
      set script_type techlib
    }
    if { [regexp "/scripts_block/" $SEV(script_file)] } {
      set script_type block
    }
    sproc_msg -info "METRIC | STRING SYS.SCRIPT_TYPE    | $script_type"

    sproc_msg -info "METRIC | STRING SYS.MACHINE        | [exec uname -n]"
    sproc_msg -info "METRIC | STRING SYS.TOOL_NAME      | $synopsys_program_name"

    if { ![info exists sh_product_version] || $sh_product_version == "" } {
      set sh_product_version NaM
    }
    sproc_msg -info "METRIC | STRING SYS.TOOL_VERSION   | $sh_product_version"

    if { $SEV(dont_run) || $SEV(dont_exit) } {
      if { $SEV(analysis_task) } {
        sproc_msg -info "METRIC | STRING SYS.TASK_TYPE      | ANALYZE_INTERACTIVE"
      } else {
        sproc_msg -info "METRIC | STRING SYS.TASK_TYPE      | OPTIMIZE_INTERACTIVE"
      }
    } else {
      if { $SEV(analysis_task) } {
        sproc_msg -info "METRIC | STRING SYS.TASK_TYPE      | ANALYZE"
      } else {
        sproc_msg -info "METRIC | STRING SYS.TASK_TYPE      | OPTIMIZE"
      }
    }

    sproc_msg -info "METRIC | TAG SYS.TAG.01 | [lindex $SVAR(tag01) 0] !! [lindex $SVAR(tag01) 1]"
    sproc_msg -info "METRIC | TAG SYS.TAG.02 | [lindex $SVAR(tag02) 0] !! [lindex $SVAR(tag02) 1]"
    sproc_msg -info "METRIC | TAG SYS.TAG.03 | [lindex $SVAR(tag03) 0] !! [lindex $SVAR(tag03) 1]"
    sproc_msg -info "METRIC | TAG SYS.TAG.04 | [lindex $SVAR(tag04) 0] !! [lindex $SVAR(tag04) 1]"
    sproc_msg -info "METRIC | TAG SYS.TAG.05 | [lindex $SVAR(tag05) 0] !! [lindex $SVAR(tag05) 1]"
    sproc_msg -info "METRIC | TAG SYS.TAG.06 | [lindex $SVAR(tag06) 0] !! [lindex $SVAR(tag06) 1]"
    sproc_msg -info "METRIC | TAG SYS.TAG.07 | [lindex $SVAR(tag07) 0] !! [lindex $SVAR(tag07) 1]"
    sproc_msg -info "METRIC | TAG SYS.TAG.08 | [lindex $SVAR(tag08) 0] !! [lindex $SVAR(tag08) 1]"
    sproc_msg -info "METRIC | TAG SYS.TAG.09 | [lindex $SVAR(tag09) 0] !! [lindex $SVAR(tag09) 1]"
    sproc_msg -info "METRIC | TAG SYS.TAG.10 | [lindex $SVAR(tag10) 0] !! [lindex $SVAR(tag10) 1]"

  }

  if { $options(-end_of_script) } {

    if { ![info exists TEV(num_jobs)] }        { set TEV(num_jobs) 1 }
    if { ![info exists TEV(num_cores)] }       { set TEV(num_cores) 1 }
    if { ![info exists TEV(num_child_jobs)] }  { set TEV(num_child_jobs) 1 }
    if { ![info exists TEV(num_child_cores)] } { set TEV(num_child_cores) 1 }

    sproc_msg -info "METRIC | INTEGER INFO.NUM_JOBS        | $TEV(num_jobs)"
    sproc_msg -info "METRIC | INTEGER INFO.NUM_CORES       | $TEV(num_cores)"
    sproc_msg -info "METRIC | INTEGER INFO.NUM_CHILD_JOBS  | $TEV(num_child_jobs)"
    sproc_msg -info "METRIC | INTEGER INFO.NUM_CHILD_CORES | $TEV(num_child_cores)"

    if { [info exists env(LSB_JOBID)] } {
      set lsf_job_id $env(LSB_JOBID)
    } else {
      set lsf_job_id NaM
    }
    sproc_msg -info "METRIC | STRING INFO.LSF_JOB_ID | $lsf_job_id"

    switch $synopsys_program_name {
      cdesigner -
      tmax_tcl -
      leda -
      mvrc -
      mvrc_shell -
      tcl {
        sproc_msg -info "METRIC | INTEGER INFO.MEMORY_USED | NaM"
      }
      pt_shell {
        if { [info exists SEV(pt_dmsa_slave)] } {
          ## -------------------------------------
          ## If running DMSA, report the max memory across the master and slaves.
          ## -------------------------------------
          remote_execute { set slave_mem_kb [mem] }
          get_distributed_variables { slave_mem_kb }
          set mem_kb_list [mem]
          foreach session [array names slave_mem_kb] {
            lappend mem_kb_list $slave_mem_kb($session)
          }
          set mem_kb [lindex [lsort -integer -decreasing $mem_kb_list] 0]
        } else {
          set mem_kb [mem]
        }
        set mem_b [expr $mem_kb * pow(2,10)]
        set mem_mb [expr int($mem_b / pow(2,20)) + 1]
        sproc_msg -info "METRIC | INTEGER INFO.MEMORY_USED | [sproc_metric_format {%d} $mem_mb]"
      }
      de_shell -
      dc_shell -
      icc_shell {
        set mem_kb [mem -all]
        set mem_b [expr $mem_kb * pow(2,10)]
        set mem_mb [expr int($mem_b / pow(2,20)) + 1]
        sproc_msg -info "METRIC | INTEGER INFO.MEMORY_USED | [sproc_metric_format {%d} $mem_mb]"
      }
      default {
        set mem_kb [mem]
        set mem_b [expr $mem_kb * pow(2,10)]
        set mem_mb [expr int($mem_b / pow(2,20)) + 1]
        sproc_msg -info "METRIC | INTEGER INFO.MEMORY_USED | [sproc_metric_format {%d} $mem_mb]"
      }
    }

    if { [info command list_licenses] == "list_licenses" } {
      redirect -var report {
        list_licenses
      }
      set license_list [list]
      set lines [split $report "\n"]
      foreach line $lines {
        if { [regexp {^\s*$} $line] } {
          continue
        }
        if { [regexp {^\s+[\w\-]+} $line] } {
          lappend license_list [lindex $line 0]
        }
      }
    } elseif { $synopsys_program_name == "tmax_tcl" } {
      redirect -var report {
        report_licenses
      }
      set license_list [list] 
      set lines [split $report "\n"]
      foreach line $lines {
        if { [regexp {^\s*$} $line] } {
          continue
        } else {
          lappend license_list [lindex $line 0]
        }
      }
    } elseif { $synopsys_program_name == "custom_designer" } {
      puts "## list CustomDesigner licenses checked out"
      foreach f [db::getFeatures] { 
        if { [db::queryFeature $f] } { puts $f } 
      }
      set license_list [list LicenseDataUnavailable]
    } else {
      set license_list [list LicenseDataUnavailable]
    }

    sproc_msg -info "METRIC | STRING INFO.LICENSES | $license_list"

  }

  set xxx2 [clock seconds]
  set xxx [expr $xxx2 - $xxx1]
  sproc_msg -info "METRICS sproc_metric_system took $xxx seconds"

  sproc_pinfo -mode stop
}

define_proc_attributes sproc_metric_system \
  -info "Used to generate metrics related to task execution." \
  -define_args {
  {-start_of_script "Indicates routine is being called at start of script execution." "" boolean optional}
  {-end_of_script "Indicates routine is being called at end of script execution." "" boolean optional}
}

## -----------------------------------------------------------------------------
## sproc_metric_time:
## -----------------------------------------------------------------------------

proc sproc_metric_time { args } {

  sproc_pinfo -mode start

  global SEV
  global SNPS_time_start SNPS_rpt_time_elapsed

  set options(-start) 0
  set options(-stop) 0

  parse_proc_arguments -args $args options

  if { $options(-start) } {
    ## This code for GMT support is not for this release.
    ## set gmt_date [clock format [clock seconds] -format "%a %b %d %H:%M:%S %Y" -gmt 1]
    ## set gmt_seconds [clock scan $gmt_date -gmt 1]
    ## sproc_msg -info "METRIC | TIMESTAMP SYS.START_TIME  | $gmt_seconds"
    sproc_msg -info "METRIC | TIMESTAMP SYS.START_TIME  | [clock seconds]"

    sproc_msg -info "SYS.START_TIME | [date]"
    set SNPS_time_start [clock seconds]
  }
  if { $options(-stop) } {
    ## This code for GMT support is not for this release.
    ## set gmt_date [clock format [clock seconds] -format "%a %b %d %H:%M:%S %Y" -gmt 1]
    ## set gmt_seconds [clock scan $gmt_date -gmt 1]
    ## sproc_msg -info "METRIC | TIMESTAMP SYS.STOP_TIME   | $gmt_seconds"
    sproc_msg -info "METRIC | TIMESTAMP SYS.STOP_TIME   | [clock seconds]"

    sproc_msg -info "SYS.STOP_TIME | [date]"
    set SNPS_time_stop [clock seconds]
    set SNPS_time_total_seconds [expr $SNPS_time_stop - $SNPS_time_start]
    set dhms [sproc_metric_time_elapsed -start $SNPS_time_start -stop $SNPS_time_stop]
    sproc_msg -info "METRIC | TIME INFO.ELAPSED_TIME.TOTAL | $SNPS_time_total_seconds"
    sproc_msg -info "INFO.ELAPSED_TIME.TOTAL | $dhms"

    ## this code generates "<>.ELAPSED_TIME.TOTAL - <>.ELAPSED_TIME.REPORT" if the metrics exist
if { 1 } {
    if { [info exists SNPS_rpt_time_elapsed] } {
      set SNPS_time_stop_minus_reports [expr $SNPS_time_stop - $SNPS_rpt_time_elapsed]
      set SNPS_time_total_minus_reports_seconds [ expr $SNPS_time_stop_minus_reports - $SNPS_time_start]
    set dhms [sproc_metric_time_elapsed -start $SNPS_time_start -stop $SNPS_time_stop_minus_reports]
      sproc_msg -info "METRIC | TIME INFO.ELAPSED_TIME.TOTAL_MINUS_REPORT | $SNPS_time_total_minus_reports_seconds"
      sproc_msg -info "INFO.ELAPSED_TIME.TOTAL_MINUS_REPORT | $dhms"
    }
}

  }

  sproc_pinfo -mode stop
}

define_proc_attributes sproc_metric_time \
  -info "Used to generate metrics related to duration of task execution." \
  -define_args {
  {-start "Indicates routine is being called to provide start time info.." "" boolean optional}
  {-stop "Indicates routine is being called to provide stop time info." "" boolean optional}
}

## -----------------------------------------------------------------------------
## sproc_metric_design:
## -----------------------------------------------------------------------------

proc sproc_metric_design { args } {

  sproc_pinfo -mode start

  global env SEV SVAR TEV
  global synopsys_program_name
  global icc_standalone_reporting_flag

  if { [regexp -nocase {NONE} $TEV(report_level)] || !$SEV(metrics_enable) } {
    sproc_pinfo -mode stop
    return
  }

  set xxx1 [clock seconds]

  parse_proc_arguments -args $args options

  set area NaM
  set cell_area NaM
  set width NaM
  set height NaM
  set chip_area NaM
  set chip_width NaM
  set chip_height NaM
  set utilization NaM
  set wire_length NaM
  set num_drc_errors NaM
  set num_drc_error_types NaM
  set num_instances NaM
  set num_flipflops NaM
  set num_modules NaM
  set num_macros NaM
  set num_ports NaM
  set num_nets NaM
  set num_pins NaM
  set grc_overflow NaM
  set vt_cells_list NaM
  set vt_cell_count_list NaM
  set vt_area_list NaM
  set ldrc_total NaM
  set ldrc_trans NaM
  set ldrc_cap NaM

  ## -------------------------------------
  ## Design metrics extraction
  ## -------------------------------------

  switch $synopsys_program_name {

    icc_shell {
      set fname $SEV(rpt_dir)/icc.report_design_physical
      if { ![file exists $fname] } {
        if { $SEV(metrics_flag_errors) } {
          sproc_msg -error   "sproc_metric_design: Unable to find file $fname for metric extraction."
        } else {
          sproc_msg -warning "sproc_metric_design: Unable to find file $fname for metric extraction."
        }
      } else {

        set fid [open $fname r]
        set lines [list]
        while { [gets $fid line] >= 0 } {
          lappend lines $line
        }
        close $fid

        set ctl1 0
        set ctl2 0
        set ctl3 0
        set ctl4 0
        set ctl5 0
        foreach line $lines {

          if { ( $ctl3 == 0 ) && [ regexp {CHIP AND CORE INFORMATION} $line ] } {
            set ctl3 1
          } elseif { (( $ctl3 == 1 ) || ( $ctl3 == 2 )) && [ regexp {^Core\s+([\d\.]+)\s+([\d\.]+)\s+([\d\.]+)} $line matchVar width height area ] } {
            incr ctl3
          } elseif { (( $ctl3 == 1 ) || ( $ctl3 == 2 )) && [ regexp {^Chip\s+([\d\.]+)\s+([\d\.]+)\s+([\d\.]+)} $line matchVar chip_width chip_height chip_area ] } {
            incr ctl3
          } elseif { $ctl3 > 1 } {
          }

          regexp {Cell/Core Ratio\s+:\s+([\d\.]+)\%} \
            $line matchVar utilization

          regexp {TOTAL LEAF CELLS\s+([\d\.]+)} \
            $line matchVar num_modules

          regexp {Macro Cells\s+([\d\.]+)} \
            $line matchVar num_macros

          regexp {Flipflops\s+([\d\.]+)} \
            $line matchVar num_flipflops

          if { ( $ctl1 == 0 ) && [ regexp {NET INFORMATION} $line ] } {
            set ctl1 1
          } elseif { ( $ctl1 == 1 ) && [ regexp {^Total\s+([\d\.]+)} $line matchVar num_nets ] } {
            set ctl1 2
          } elseif { $ctl1 > 1 } {
          }

          if { ( $ctl2 == 0 ) && [ regexp {PORT and PIN INFORMATION} $line ] } {
            set ctl2 1
          } elseif { (( $ctl2 == 1 ) || ( $ctl2 == 2 )) && [ regexp {^Leaf\s+([\d\.]+)} $line matchVar num_pins ] } {
            incr ctl2
          } elseif { (( $ctl2 == 1 ) || ( $ctl2 == 2 )) && [ regexp {^Ports\s+([\d\.]+)} $line matchVar num_ports ] } {
            incr ctl2
          } elseif { $ctl2 > 2 } {
          }

          if { ( $ctl4 == 0 ) && [ regexp {Signal Wiring Statistics:} $line ] } {
            set ctl4 1
          } elseif { ( $ctl4 == 1 ) && [ regexp {Total Wire Length\(count\):\s+([\d\.]+)} $line matchVar wire_length ] } {
            set ctl4 2
          } elseif { $ctl4 > 1 } {
          }

          if { ( $ctl5 == 0 ) && [ regexp {DRC information:} $line ] } {
            set ctl5 1
            set num_drc_error_types 0
          } elseif { ( $ctl5 == 1 ) && [ regexp {Total error number:\s+([\d\.]+)} $line matchVar num_drc_errors ] } {
            set ctl5 2
          } elseif { ( $ctl5 == 1 ) } {
            incr num_drc_error_types 
            if { [ regexp {\s+(.*):\s+([\d\.]+)} $line matchVar error_type error_cnt ] } {
              sproc_msg -info   "DRC : count = $error_cnt type = \"$error_type\""
            } else {
              sproc_msg -error   "sproc_metric_design: failure to part DRC error types properly."
            }
          } elseif { $ctl5 > 1 } {
          }

        }
      }
      set fname $SEV(rpt_dir)/icc.report_qor
      if { ![file exists $fname] } {
        if { $SEV(metrics_flag_errors) } {
          sproc_msg -error   "sproc_metric_design: Unable to find file $fname for metric extraction."
        } else {
          sproc_msg -warning "sproc_metric_design: Unable to find file $fname for metric extraction."
        }
      } else {
        set fid [open $fname r]
        set lines [list]
        while { [gets $fid line] >= 0 } {
          lappend lines $line
        }
        close $fid
        foreach line $lines {
          regexp {Cell Area:\s+([\d\.]+)} \
            $line matchVar cell_area
        }
      }

    }

      de_shell -
      dc_shell {
      set fname $SEV(rpt_dir)/dc.report_qor
      if { ![file exists $fname] } {
        if { $SEV(metrics_flag_errors) } {
          sproc_msg -error   "sproc_metric_design: Unable to find file $fname for metric extraction."
        } else {
          sproc_msg -warning "sproc_metric_design: Unable to find file $fname for metric extraction."
        }
      } else {
        set fid [open $fname r]
        set lines [list]
        while { [gets $fid line] >= 0 } {
          lappend lines $line
        }
        close $fid
        foreach line $lines {
          regexp {Leaf Cell Count:\s+([\d\.]+)} \
            $line matchVar num_instances
          regexp {Total Number of Nets:\s+([\d\.]+)} \
            $line matchVar num_nets
          regexp {Cell Area:\s+([\d\.]+)} \
            $line matchVar cell_area
        }
        set num_ports [sizeof_collection [get_ports *]]
        set instances [get_cells -hierarchical -filter "is_hierarchical==false"]
        set instances [filter $instances "ref_name!=**logic_0**"]
        set instances [filter $instances "ref_name!=**logic_1**"]
        set num_pins [sizeof_collection [get_pins -of_objects $instances]]
      }

    }

    default {
      sproc_msg -error "sproc_metric_design: unrecognized tool name"
    }

  }

  ## -------------------------------------
  ## Congestion metric extraction
  ## -------------------------------------

  switch $synopsys_program_name {

    dc_shell -
    icc_shell {
      if { $synopsys_program_name == "dc_shell" } {
        set fname $SEV(rpt_dir)/dc.report_congestion
      } else {
        set fname $SEV(rpt_dir)/icc.report_congestion
      }
      if { [file exists $fname] } {
        set fid [open $fname r]
        set lines [list]
        while { [gets $fid line] >= 0 } {
          regexp {Both Dirs: Overflow.*\(([\d\.]+)%\)} $line matchVar grc_overflow
        }
        close $fid
      }
    }
    de_shell {
      ## NOP
    }
    default {
      sproc_msg -error "sproc_metric_design: unrecognized tool name"
    }
  }

  ## -------------------------------------
  ## Vth metrics extraction
  ## -------------------------------------

  set vt_item_list [list]

  switch $synopsys_program_name {

    de_shell -
    dc_shell -
    icc_shell {
      if { $synopsys_program_name == "dc_shell" || $synopsys_program_name == "de_shell" } {
        set fname $SEV(rpt_dir)/dc.report_threshold_voltage_group
      } else {
        set fname $SEV(rpt_dir)/icc.report_threshold_voltage_group
      }
      if { ![file exists $fname] } {
        if { $SEV(metrics_flag_errors) } {
          sproc_msg -error   "sproc_metric_design: Unable to find file $fname for metric extraction."
        } else {
          sproc_msg -warning "sproc_metric_design: Unable to find file $fname for metric extraction."
        }
      } else {
        set vt_cells_list ""
        set vt_cell_count_list ""
        set vt_area_list ""
        set fid [open $fname r]
        set lines [list]
        while { [gets $fid line] >= 0 } {
          lappend lines $line
        }
        close $fid
        set mode 0
        foreach line $lines {
          if { ( $mode == 0 ) && [ regexp {Threshold Voltage Group Report} $line ] } {
            set mode 1
          } elseif { ( $mode == 1 ) && [ regexp {\*\*\*\*\*\*\*\*\*\*} $line ] } {
            set mode 2
          } elseif { ( $mode == 2 ) && [ regexp {\*\*\*\*\*\*\*\*\*\*} $line ] } {
            set mode 3
          } elseif { ( $mode == 3 ) && [ regexp {\*\*\*\*\*\*\*\*\*\*} $line ] } {
            set mode 4
          } elseif { ( $mode == 4 ) && [ regexp {\*\*\*\*\*\*\*\*\*\*} $line ] } {
            set mode 5
          } elseif { ( $mode == 2 ) } {
            ## Parse for either current or pre-2010.03 format reports
            if { [regexp {\s*([\w\.]+)\s+([\d\.]+)\s+\(([\d\.]+)%\)} \
                          $line matchVar vt_name num_inst vt_percent] || \
                 [regexp {\s*([\w\.]+)\s+([\d\.]+)\s+([\d\.]+)%} \
                          $line matchVar vt_name num_inst vt_percent] } {
              set vt_cells "$vt_name $vt_percent"
              set vt_cell_count "$vt_name $num_inst"
              lappend vt_cells_list $vt_cells
              lappend vt_cell_count_list $vt_cell_count
            }
          } elseif { ( $mode == 4 ) } {
            ## Parse for either current or pre-2010.03 format reports
            if { [regexp {\s*([\w\.]+)\s+([\d\.]+)\s+\(([\d\.]+)%\)} \
                         $line matchVar vt_name num_area vt_percent] || \
                 [regexp {\s*([\w\.]+)\s+([\d\.]+)\s+([\d\.]+)%} \
                         $line matchVar vt_name num_area vt_percent] } {
              set vt_area "$vt_name $vt_percent"
              lappend vt_area_list $vt_area
            }
          }
        }
      }
    }

    default {
      sproc_msg -error "sproc_metric_design: unrecognized tool name"
    }

  }

  switch $synopsys_program_name {
    de_shell -
    dc_shell {
    }
    icc_shell {
      ##
      ## These metrics are not currently being captured for dc_shell.
      ## Set them to a value that will pass the error checking.
      ##
      set num_instances 0
      if { [string is integer $num_modules] } {
        set num_instances [expr $num_instances + $num_modules]
      }
      if { [string is integer $num_macros] } {
        set num_instances [expr $num_instances + $num_macros]
      }
      if { $num_instances == 0 } {
        set num_instances NaM
      }
    }
  }

  ## -------------------------------------
  ## Logic DRC metric extraction
  ## -------------------------------------

  switch $synopsys_program_name {
    de_shell -
    dc_shell -
    icc_shell {
      if { $synopsys_program_name == "dc_shell" } {
        set fname $SEV(rpt_dir)/dc.report_qor
      } else {
        set fname $SEV(rpt_dir)/icc.report_qor
      }
      if { [file exists $fname] } {
        set fid [open $fname r]
        set lines [list]
        set mode 0
        while { [gets $fid line] >= 0 } {
          if { ( $mode == 0 ) && [ regexp {Design Rules} $line ] } {
            set mode 1
          } elseif { ( $mode == 1 ) && [ regexp {([-]+)} $line ] } {
            set mode 2
          } elseif { ( $mode == 2 ) && [ regexp {Total Number of Nets} $line ] } {
            set mode 3
          } elseif { ( $mode == 3 ) && [ regexp {([-]+)} $line ] } {
            set mode 4
          } elseif { ( $mode == 3 ) && [ regexp {Nets With Violations:\s+([\d]+)} $line matchVar ldrc_total ] } {
            set ldrc_trans 0
            set ldrc_cap 0
          } elseif { ( $mode == 3 ) && [ regexp {Max Trans Violations:\s+([\d]+)} $line matchVar ldrc_trans ] } {
          } elseif { ( $mode == 3 ) && [ regexp {Max Cap Violations:\s+([\d]+)} $line matchVar ldrc_cap ] } {
          } else {
          }
        }
        close $fid
      }
    }
    default {
      sproc_msg -error "sproc_metric_design: unrecognized tool name"
    }
  }

  ## -------------------------------------
  ## Perform a bit of error checking.
  ## -------------------------------------

  if { $area == "NaM" } {
    if { $chip_area == "NaM" } {
      sproc_msg -info "Missing metric: area"
    } else {
      sproc_msg -info "Metric: area resorting to chip_area, likely rectilinear."
      set area $chip_area
    }
  }
  if { $width == "NaM" } {
    if { $chip_width == "NaM" } {
      sproc_msg -info "Missing metric: width"
    } else {
      sproc_msg -info "Metric: width resorting to chip_width, likely rectilinear."
      set width $chip_width
    }
  }
  if { $height == "NaM" } {
    if { $chip_height == "NaM" } {
      sproc_msg -info "Missing metric: height"
    } else {
      sproc_msg -info "Metric: height resorting to chip_height, likely rectilinear."
      set height $chip_height
    }
  }
  if { $utilization   == "NaM" } { sproc_msg -info "Missing metric: utilization" }
  if { $wire_length   == "NaM" } { sproc_msg -info "Missing metric: wire_length" }
  if { $num_drc_errors    == "NaM" } { sproc_msg -info "Missing metric: num_drc_errors" }
  if { $num_drc_error_types    == "NaM" } { sproc_msg -info "Missing metric: num_drc_error_types" }

  if { $num_macros    == "NaM" } { sproc_msg -info "Missing metric: num_macros" }
  if { $num_macros    == "NaM" } { sproc_msg -info "Missing metric: num_modules" }
  if { $num_instances == "NaM" } { sproc_msg -info "Missing metric: num_instances" }
  if { $num_flipflops == "NaM" } { sproc_msg -info "Missing metric: num_flipflops" }

  if { $num_ports     == "NaM" } { sproc_msg -info "Missing metric: num_ports" }
  if { $num_nets      == "NaM" } { sproc_msg -info "Missing metric: num_nets" }
  if { $num_pins      == "NaM" } { sproc_msg -info "Missing metric: num_pins" }
  if { $cell_area      == "NaM" } { sproc_msg -info "Missing metric: cell_area" }

  sproc_msg -info "METRIC | DOUBLE  PHYSICAL.AREA | [sproc_metric_format {%f} $area]"
  sproc_msg -info "METRIC | DOUBLE  PHYSICAL.WIDTH | [sproc_metric_format {%f} $width]"
  sproc_msg -info "METRIC | DOUBLE  PHYSICAL.HEIGHT | [sproc_metric_format {%f} $height]"
  sproc_msg -info "METRIC | PERCENT PHYSICAL.UTIL | $utilization"
  sproc_msg -info "METRIC | DOUBLE  PHYSICAL.WLENGTH | [sproc_metric_format {%f} $wire_length]"
  sproc_msg -info "METRIC | PERCENT PHYSICAL.CONGESTION | $grc_overflow"
  sproc_msg -info "METRIC | INTEGER VERIFY.DRC.NUM_ERRORS | $num_drc_errors"
  sproc_msg -info "METRIC | INTEGER VERIFY.DRC.NUM_TYPES | $num_drc_error_types"
  sproc_msg -info "METRIC | STRING  VERIFY.DRC.TOOL | ICC"

  sproc_msg -info "METRIC | DOUBLE  LOGICAL.CELL_AREA | [sproc_metric_format {%f} $cell_area]"
  sproc_msg -info "METRIC | INTEGER LOGICAL.NUM_MACROS | $num_macros"
  sproc_msg -info "METRIC | INTEGER LOGICAL.NUM_MODULES | $num_modules"
  sproc_msg -info "METRIC | INTEGER LOGICAL.NUM_INSTS | $num_instances"
  sproc_msg -info "METRIC | INTEGER LOGICAL.NUM_FLIPFLOPS | $num_flipflops"
  sproc_msg -info "METRIC | INTEGER LOGICAL.NUM_PORTS | $num_ports"
  sproc_msg -info "METRIC | INTEGER LOGICAL.NUM_NETS | $num_nets"
  sproc_msg -info "METRIC | INTEGER LOGICAL.NUM_PINS | $num_pins"

  if { $vt_cells_list == "NaM" || [llength $vt_cells_list] == 0 } { 
    sproc_msg -info "Missing Vth metric information. (percent cells)" 
    sproc_msg -info "METRIC | PERCENT PWR.VTH_PERCENT_CELLS.NO_VTH_INFO | NaM"
  } else {
    foreach vt_cells $vt_cells_list {
      set vt_name    [lindex $vt_cells 0]
      set vt_percent [lindex $vt_cells 1]
      sproc_msg -info "METRIC | PERCENT PWR.VTH_PERCENT_CELLS.$vt_name | $vt_percent"
    }
  }

  if { $vt_cell_count_list == "NaM" || [llength $vt_cell_count_list] == 0 } {
    sproc_msg -info "Missing Vth metric information. (instance count)"
    sproc_msg -info "METRIC | INTEGER PWR.VTH_NUM_INSTS.NO_VTH_INFO | NaM"
  } else {
    foreach vt_cell_count $vt_cell_count_list {
      set vt_name    [lindex $vt_cell_count 0]
      set vt_count [lindex $vt_cell_count 1]
      sproc_msg -info "METRIC | INTEGER PWR.VTH_NUM_INSTS.$vt_name | $vt_count"
    }
  }

  if { $vt_area_list == "NaM" || [llength $vt_area_list] == 0 } {
    sproc_msg -info "Missing Vth metric information. (percent area)"
    sproc_msg -info "METRIC | PERCENT PWR.VTH_PERCENT_AREA.NO_VTH_INFO | NaM"
  } else {
    foreach vt_area $vt_area_list {
      set vt_name    [lindex $vt_area 0]
      set vt_percent [lindex $vt_area 1]
      sproc_msg -info "METRIC | PERCENT PWR.VTH_PERCENT_AREA.$vt_name | $vt_percent"
    }
  }

  if { $ldrc_total == "NaM" } {
    sproc_msg -info "Missing logical DRC metric information."
    sproc_msg -info "METRIC | INTEGER STA.LDRC.TOTAL | NaM"
  } else {
    sproc_msg -info "METRIC | INTEGER STA.LOGICAL_DRC.TOTAL | $ldrc_total"
    sproc_msg -info "METRIC | INTEGER STA.LOGICAL_DRC.TRANS | $ldrc_trans"
    sproc_msg -info "METRIC | INTEGER STA.LOGICAL_DRC.CAP | $ldrc_cap"
  }

  set xxx2 [clock seconds]
  set xxx [expr $xxx2 - $xxx1]
  sproc_msg -info "METRICS sproc_metric_design took $xxx seconds"

  sproc_pinfo -mode stop
}

define_proc_attributes sproc_metric_design \
  -info "Gathers design information for metrics reporting." \
  -define_args {
}

## -----------------------------------------------------------------------------
## sproc_clean_string:
## -----------------------------------------------------------------------------

proc sproc_clean_string { args } {

  sproc_pinfo -mode start

  set options(-string) ""
  parse_proc_arguments -args $args options

  set string_before $options(-string)

  set string_after [regsub -all {[\*]} $string_before {}]
  set string_after [regsub -all {[\/\-\(\)\[\]\=\%\&\@\!\~]} $string_after {_}]

  if {![regexp $string_after $string_before]} {
    sproc_msg -warn "string $string_before changed to $string_after to remove hazardous characters"
  }

  sproc_pinfo -mode stop

  return $string_after

}

define_proc_attributes sproc_clean_string \
  -info "removes characters not supported for metric strings" \
  -define_args {
  {-string  "The string that needs cleaning." AString string required}
}

## -----------------------------------------------------------------------------
## sproc_metric_sta:
## -----------------------------------------------------------------------------

proc sproc_metric_sta { args } {

  sproc_pinfo -mode start

  global env SEV SVAR TEV
  global synopsys_program_name
  global pt_shell_mode
  global icc_standalone_reporting_flag

  if { [regexp -nocase {NONE} $TEV(report_level)] || !$SEV(metrics_enable) } {
    sproc_pinfo -mode stop
    return
  }

  set xxx1 [clock seconds]

  set options(-scenario) ""
  parse_proc_arguments -args $args options

  switch $synopsys_program_name {

    pt_shell {

      switch $pt_shell_mode {
        primetime {
          if { [llength $options(-scenario)] != 1  } {
            sproc_msg -error "A single scenario must be specified."
          } else {
            set RPT(basename) $SEV(rpt_dir)/pt.$options(-scenario)
          }
        }
        primetime_master {
          if { [llength $options(-scenario)] != 1  } {
            sproc_msg -error "A single scenario must be specified."
          } else {
            set RPT(basename) $SEV(rpt_dir)/pt.dmsa.$options(-scenario)
          }
        }
        primetime_slave {
          sproc_msg -error "This procedure not supported for primetime_slave"
          sproc_pinfo -mode stop
          return
        }
      }

      ## -------------------------------------
      ## Establishing units used in PT reports
      ## -------------------------------------

      set time_unit undefined

      set fname $RPT(basename).report_units

      if { ![file exists $fname] } {
        if { $SEV(metrics_flag_errors) } {
          sproc_msg -error   "sproc_metric_sta: Unable to find file $fname for metric extraction."
        } else {
          sproc_msg -warning "sproc_metric_sta: Unable to find file $fname for metric extraction."
        }
      } else {

        set fid [open $fname r]
        set string_file [read $fid]
        close $fid
        set lines [split $string_file \n]

        foreach line $lines {
          puts $line
          if { [regexp {\s(\S+)\s+Second} $line match value] } {
            switch $value {
              1e-00 { set time_unit s }
              1e-03 { set time_unit ms }
              1e-06 { set time_unit us }
              1e-09 { set time_unit ns }
              1e-12 { set time_unit ps }
              1e-15 { set time_unit fs }
              default {
                sproc_msg -error "Time unit $value not recognized."
              }
            }
          }
        }

      }

      sproc_msg -info "PrimeTime time unit is $time_unit"

      set fname $RPT(basename).report_qor

      if { ![file exists $fname] } {
        if { $SEV(metrics_flag_errors) } {
          sproc_msg -error   "sproc_metric_sta: Unable to find file $fname for metric extraction."
        } else {
          sproc_msg -warning "sproc_metric_sta: Unable to find file $fname for metric extraction."
        }
      } else {

        set fid [open $fname r]
        set string_file [read $fid]
        close $fid
        set lines [split $string_file \n]

        foreach line $lines {
          if { [regexp {^\s+Timing Path Group\s+\'(.*)\'} $line matchVar group_name] } {
            set group_name [regsub -all -- {\*} $group_name {}]
            set group_name [regsub -all -- {[()-/]} $group_name {_}]
          }
          if { [regexp {^\s+Scenario\s+\'(.*)\'} $line matchVar scenario_name] } {
            set scenario scenario_name
          }

          if { [regexp {^\s+Levels of Logic:\s+([\-\d\.]+)} $line matchVar data] } {
            set value $data
            sproc_msg -info "METRIC | DOUBLE STA.LOGIC_LEVELS_MAX.[sproc_clean_string -string $group_name.$scenario] | $value"
          }

          if { [regexp {^\s+Critical Path Slack:\s+([\-\d\.]+)} $line matchVar data] } {
            set value [sproc_metric_format {%f} [sproc_metric_normalize -value $data -current_unit $time_unit]]
            sproc_msg -info "METRIC | DOUBLE STA.WNS_MAX.[sproc_clean_string -string $group_name.$scenario] | $value"
          }
          if { [regexp {^\s+Worst Hold Violation:\s+([\-\d\.]+)} $line matchVar data] } {
            set value [sproc_metric_format {%f} [sproc_metric_normalize -value $data -current_unit $time_unit]]
            sproc_msg -info "METRIC | DOUBLE STA.WNS_MIN.[sproc_clean_string -string $group_name.$scenario] | $value"
          }

          if { [regexp {^\s+Total Negative Slack:\s+([\-\d\.]+)} $line matchVar data] } {
            set value [sproc_metric_format {%f} [sproc_metric_normalize -value $data -current_unit $time_unit]]
            sproc_msg -info "METRIC | DOUBLE STA.TNS_MAX.[sproc_clean_string -string $group_name.$scenario] | $value"
          }
          if { [regexp {^\s+Total Hold Violation:\s+([\-\d\.]+)} $line matchVar data] } {
            set value [sproc_metric_format {%f} [sproc_metric_normalize -value $data -current_unit $time_unit]]
            sproc_msg -info "METRIC | DOUBLE STA.TNS_MIN.[sproc_clean_string -string $group_name.$scenario] | $value"
          }

          if { [regexp {^\s+No. of Violating Paths:\s+([\-\d\.]+)} $line matchVar data] } {
            set data [expr int($data)]
            sproc_msg -info "METRIC | INTEGER STA.NVP_MAX.[sproc_clean_string -string $group_name.$scenario] | $data"
          }
          if { [regexp {^\s+No. of Hold Violations:\s+([\-\d\.]+)} $line matchVar data] } {
            set data [expr int($data)]
            sproc_msg -info "METRIC | INTEGER STA.NVP_MIN.[sproc_clean_string -string $group_name.$scenario] | $data"
          }
        }

      }

      ## -------------------------------------
      ## Clock processing
      ## -------------------------------------

      set fname $RPT(basename).report_clock_timing
      if { ![file exists $fname] } {
        sproc_msg -info "Unable to generate clock metric unable to find file = \"$fname\"."
      } else {

        set fid [open $fname r]
        set lines [list]
        while { [gets $fid line] >= 0 } {
          lappend lines $line
        }
        close $fid

        set mode 0
        set scenario $TEV(scenario)

        foreach line $lines {

          if { [regexp {^\s+Clock:\s+([\w]+)\s*$} $line matchVar clock_name] } {
            set name [regsub -all {\/} $clock_name {_}]
          }

          if { [regexp {^\s+Maximum setup skew:\s*$} $line ] } {
            set mode 1
          } elseif { $mode == 1 } {
            set mode 2
          } elseif { $mode == 2 } {
            regexp {\s*\S+\s+([\d\.\-]+)\s+} $line match skew
            set mode 0
            sproc_msg -info "$name : $skew"
            set metric_value [sproc_metric_format {%f} [sproc_metric_normalize -value $skew -current_unit $time_unit]]
            sproc_msg -info "METRIC | DOUBLE STA.CLK_SKEW.[sproc_clean_string -string $name.$scenario] | $metric_value"
          } elseif { [regexp {^\s+Maximum setup launch latency:\s*$} $line ]  } {
            set mode 3
          } elseif { $mode == 3 } {
            regexp {\s*\S+\s+([\d\.\-]+)\s+} $line match latency
            set mode 0
            sproc_msg -info "$name : $latency"
            set metric_value [sproc_metric_format {%f} [sproc_metric_normalize -value $latency -current_unit $time_unit]]
            sproc_msg -info "METRIC | DOUBLE STA.CLK_LATENCY_MAX.[sproc_clean_string -string $name.$scenario] | $metric_value"
          } elseif { [regexp {^\s+Minimum setup capture latency:\s*$} $line ]  } {
            set mode 4
          } elseif { $mode == 4 } {
            regexp {\s*\S+\s+([\d\.\-]+)\s+} $line match latency
            set mode 0
            sproc_msg -info "$name : $latency"
            set metric_value [sproc_metric_format {%f} [sproc_metric_normalize -value $latency -current_unit $time_unit]]
            sproc_msg -info "METRIC | DOUBLE STA.CLK_LATENCY_MIN.[sproc_clean_string -string $name.$scenario] | $metric_value"
          }
        }

      }

    }

    de_shell -
    dc_shell -
    icc_shell {

      if { $synopsys_program_name == "icc_shell" } {
        set fname "$SEV(rpt_dir)/icc.report_units"
      } else {
        set fname "$SEV(rpt_dir)/dc.report_units"
      }
      if { ![file exists $fname] } {

        if { $SEV(metrics_flag_errors) } {
          sproc_msg -error   "sproc_metric_sta: Unable to find file $fname for metric normalization."
        } else {
          sproc_msg -warning "sproc_metric_sta: Unable to find file $fname for metric normalization."
        }

      } else {
        set fid [open $fname r]
        set lines [list]
        while { [gets $fid line] >= 0 } {
          lappend lines $line
        }
        close $fid
        set time_unit "undefined"
        foreach line $lines {
          if { [regexp "Time_unit.*\((.\s+)\)" $line matchVar time_unit] } {
            sproc_msg -info "time_unit: $time_unit"
            break
          }
        }

        if { $time_unit == "undefined" } {
          sproc_msg -issue "The report_units $fname report is returning a time unit of N/A."
          set time_unit ns
        }
      }

      if { $synopsys_program_name == "icc_shell" } {
        set fname "$SEV(rpt_dir)/icc.report_qor"
      } else {
        set fname "$SEV(rpt_dir)/dc.report_qor"
      }


      if { ![file exists $fname] } {
        if { $SEV(metrics_flag_errors) } {
          sproc_msg -error   "sproc_metric_sta: Unable to find file $fname for metric extraction."
        } else {
          sproc_msg -warning "sproc_metric_sta: Unable to find file $fname for metric extraction."
        }
      } else {

        set fid [open $fname r]
        set lines [list]
        while { [gets $fid line] >= 0 } {
          lappend lines $line
        }
        close $fid

        set group_name GROUP_NOT_SPECIFIED
        set scenario SCENARIO_NOT_SPECIFIED
        foreach line $lines {

          if { [regexp {^\s+Timing Path Group\s+\'(.*)\'} $line matchVar group_name] } {
            set group_name [regsub -all -- {\*} $group_name {}]
            set group_name [regsub -all -- {[()-/]} $group_name {_}]
          }
          regexp {^\s+Scenario\s+\'(.*)\'} $line matchVar scenario

          if { [regexp {^\s+Critical Path Slack:\s+([\-\d\.]+)} $line matchVar data] } {
            set value [sproc_metric_format {%f} [sproc_metric_normalize -value $data -current_unit $time_unit]]
            sproc_msg -info "METRIC | DOUBLE STA.WNS_MAX.[sproc_clean_string -string $group_name.$scenario] | $value"
          }
          if { [regexp {^\s+Total Negative Slack:\s+([\-\d\.]+)} $line matchVar data] } {
            set value [sproc_metric_format {%f} [sproc_metric_normalize -value $data -current_unit $time_unit]]
            sproc_msg -info "METRIC | DOUBLE STA.TNS_MAX.[sproc_clean_string -string $group_name.$scenario] | $value"
          }
          if { [regexp {^\s+No. of Violating Paths:\s+([\-\d\.]+)} $line matchVar data] } {
            set data [expr int($data)]
            sproc_msg -info "METRIC | INTEGER STA.NVP_MAX.[sproc_clean_string -string $group_name.$scenario] | $data"
          }
          if { [regexp {^\s+Levels of Logic:\s+([\-\d\.]+)} $line matchVar data] } {
            set value $data
            sproc_msg -info "METRIC | DOUBLE STA.LOGIC_LEVELS_MAX.[sproc_clean_string -string $group_name.$scenario] | $value"
          }
          if { [regexp {^\s+Worst Hold Violation:\s+([\-\d\.]+)} $line matchVar data] } {
            set value [sproc_metric_format {%f} [sproc_metric_normalize -value $data -current_unit $time_unit]]
            sproc_msg -info "METRIC | DOUBLE STA.WNS_MIN.[sproc_clean_string -string $group_name.$scenario] | $value"
          }
          if { [regexp {^\s+Total Hold Violation:\s+([\-\d\.]+)} $line matchVar data] } {
            set value [sproc_metric_format {%f} [sproc_metric_normalize -value $data -current_unit $time_unit]]
            sproc_msg -info "METRIC | DOUBLE STA.TNS_MIN.[sproc_clean_string -string $group_name.$scenario] | $value"
          }
          if { [regexp {^\s+No. of Hold Violations:\s+([\-\d\.]+)} $line matchVar data] } {
            set data [expr int($data)]
            sproc_msg -info "METRIC | INTEGER STA.NVP_MIN.[sproc_clean_string -string $group_name.$scenario] | $data"
          }

          ##
          ## the next group of metrics comes from "report_qor -summary" for ICC
          ##
          if { [ regexp {^\s+Scenario:\s+([\w\.]+)\s+WNS:\s+([\d\.]+)\s+TNS:\s+([\d\.]+)\s+Number of Violating Paths:\s+([\d]+)} $line matchVar t_scenario t_wns t_tns t_nvp ] } {
            set t_wns [ expr -1.0 * [sproc_metric_format {%f} [sproc_metric_normalize -value $t_wns -current_unit $time_unit]] ]
            set t_tns [ expr -1.0 * [sproc_metric_format {%f} [sproc_metric_normalize -value $t_tns -current_unit $time_unit]] ]
            set t_nvp [expr int($t_nvp)]
            sproc_msg -info "METRIC | DOUBLE STA.WNS_MAX.SCENARIO.[sproc_clean_string -string $t_scenario] | $t_wns"
            sproc_msg -info "METRIC | DOUBLE STA.TNS_MAX.SCENARIO.[sproc_clean_string -string $t_scenario] | $t_tns"
            sproc_msg -info "METRIC | INTEGER STA.NVP_MAX.SCENARIO.[sproc_clean_string -string $t_scenario] | $t_nvp"
          }
          if { [ regexp {^\s+Scenario:\s+([\w\.]+)\s+\(Hold\) WNS:\s+([\d\.]+)\s+TNS:\s+([\d\.]+)\s+Number of Violating Paths:\s+([\d]+)} $line matchVar t_scenario t_wns t_tns t_nvp ] } {
            set t_wns [ expr -1.0 * [sproc_metric_format {%f} [sproc_metric_normalize -value $t_wns -current_unit $time_unit]] ]
            set t_tns [ expr -1.0 * [sproc_metric_format {%f} [sproc_metric_normalize -value $t_tns -current_unit $time_unit]] ]
            set t_nvp [expr int($t_nvp)]
            sproc_msg -info "METRIC | DOUBLE STA.WNS_MIN.SCENARIO.[sproc_clean_string -string $t_scenario] | $t_wns"
            sproc_msg -info "METRIC | DOUBLE STA.TNS_MIN.SCENARIO.[sproc_clean_string -string $t_scenario] | $t_tns"
            sproc_msg -info "METRIC | INTEGER STA.NVP_MIN.SCENARIO.[sproc_clean_string -string $t_scenario] | $t_nvp"
          }
          if { [ regexp {^\s+Multi-Scenario\s+WNS:\s+([\d\.]+)\s+TNS:\s+([\d\.]+)\s+Number of Violating Paths:\s+([\d]+)} $line matchVar t_wns t_tns t_nvp ] } {
            set t_wns [ expr -1.0 * [sproc_metric_format {%f} [sproc_metric_normalize -value $t_wns -current_unit $time_unit]] ]
            set t_tns [ expr -1.0 * [sproc_metric_format {%f} [sproc_metric_normalize -value $t_tns -current_unit $time_unit]] ]
            set t_nvp [expr int($t_nvp)]
            sproc_msg -info "METRIC | DOUBLE STA.WNS_MAX.MULTI_SCENARIO | $t_wns"
            sproc_msg -info "METRIC | DOUBLE STA.TNS_MAX.MULTI_SCENARIO | $t_tns"
            sproc_msg -info "METRIC | INTEGER STA.NVP_MAX.MULTI_SCENARIO | $t_nvp"
          }
          if { [ regexp {^\s+Multi-Scenario\s+\(Hold\)\s+WNS:\s+([\d\.]+)\s+TNS:\s+([\d\.]+)\s+Number of Violating Paths:\s+([\d]+)} $line matchVar t_wns t_tns t_nvp ] } {
            set t_wns [ expr -1.0 * [sproc_metric_format {%f} [sproc_metric_normalize -value $t_wns -current_unit $time_unit]] ]
            set t_tns [ expr -1.0 * [sproc_metric_format {%f} [sproc_metric_normalize -value $t_tns -current_unit $time_unit]] ]
            set t_nvp [expr int($t_nvp)]
            sproc_msg -info "METRIC | DOUBLE STA.WNS_MIN.MULTI_SCENARIO | $t_wns"
            sproc_msg -info "METRIC | DOUBLE STA.TNS_MIN.MULTI_SCENARIO | $t_tns"
            sproc_msg -info "METRIC | INTEGER STA.NVP_MIN.MULTI_SCENARIO | $t_nvp"
          }

          ##
          ## the next group of metrics comes from "report_qor -summary" for ICC w/ "signoff_opt"
          ##
          if { [ regexp {^\s+Scenario:\s+([\w\.]+)\s+\(SETUP\)\s+WNS:\s+([\d\.]+)\s+TNS:\s+([\d\.]+)\s+Number of Violating Paths:\s+([\d]+)} $line matchVar t_scenario t_wns t_tns t_nvp ] } {
            set t_wns [ expr -1.0 * [sproc_metric_format {%f} [sproc_metric_normalize -value $t_wns -current_unit $time_unit]] ]
            set t_tns [ expr -1.0 * [sproc_metric_format {%f} [sproc_metric_normalize -value $t_tns -current_unit $time_unit]] ]
            set t_nvp [expr int($t_nvp)]
            sproc_msg -info "METRIC | DOUBLE STA.WNS_MAX.SCENARIO.[sproc_clean_string -string $t_scenario] | $t_wns"
            sproc_msg -info "METRIC | DOUBLE STA.TNS_MAX.SCENARIO.[sproc_clean_string -string $t_scenario] | $t_tns"
            sproc_msg -info "METRIC | INTEGER STA.NVP_MAX.SCENARIO.[sproc_clean_string -string $t_scenario] | $t_nvp"
          }
          if { [ regexp {^\s+Scenario:\s+([\w\.]+)\s+\(HOLD\) WNS:\s+([\d\.]+)\s+TNS:\s+([\d\.]+)\s+Number of Violating Paths:\s+([\d]+)} $line matchVar t_scenario t_wns t_tns t_nvp ] } {
            set t_wns [ expr -1.0 * [sproc_metric_format {%f} [sproc_metric_normalize -value $t_wns -current_unit $time_unit]] ]
            set t_tns [ expr -1.0 * [sproc_metric_format {%f} [sproc_metric_normalize -value $t_tns -current_unit $time_unit]] ]
            set t_nvp [expr int($t_nvp)]
            sproc_msg -info "METRIC | DOUBLE STA.WNS_MIN.SCENARIO.[sproc_clean_string -string $t_scenario] | $t_wns"
            sproc_msg -info "METRIC | DOUBLE STA.TNS_MIN.SCENARIO.[sproc_clean_string -string $t_scenario] | $t_tns"
            sproc_msg -info "METRIC | INTEGER STA.NVP_MIN.SCENARIO.[sproc_clean_string -string $t_scenario] | $t_nvp"
          }
          if { [ regexp {^\s+Multi-Scenario\s+\(SETUP\)\s+WNS:\s+([\d\.]+)\s+TNS:\s+([\d\.]+)\s+Number of Violating Paths:\s+([\d]+)} $line matchVar t_wns t_tns t_nvp ] } {
            set t_wns [ expr -1.0 * [sproc_metric_format {%f} [sproc_metric_normalize -value $t_wns -current_unit $time_unit]] ]
            set t_tns [ expr -1.0 * [sproc_metric_format {%f} [sproc_metric_normalize -value $t_tns -current_unit $time_unit]] ]
            set t_nvp [expr int($t_nvp)]
            sproc_msg -info "METRIC | DOUBLE STA.WNS_MAX.MULTI_SCENARIO | $t_wns"
            sproc_msg -info "METRIC | DOUBLE STA.TNS_MAX.MULTI_SCENARIO | $t_tns"
            sproc_msg -info "METRIC | INTEGER STA.NVP_MAX.MULTI_SCENARIO | $t_nvp"
          }
          if { [ regexp {^\s+Multi-Scenario\s+\(HOLD\)\s+WNS:\s+([\d\.]+)\s+TNS:\s+([\d\.]+)\s+Number of Violating Paths:\s+([\d]+)} $line matchVar t_wns t_tns t_nvp ] } {
            set t_wns [ expr -1.0 * [sproc_metric_format {%f} [sproc_metric_normalize -value $t_wns -current_unit $time_unit]] ]
            set t_tns [ expr -1.0 * [sproc_metric_format {%f} [sproc_metric_normalize -value $t_tns -current_unit $time_unit]] ]
            set t_nvp [expr int($t_nvp)]
            sproc_msg -info "METRIC | DOUBLE STA.WNS_MIN.MULTI_SCENARIO | $t_wns"
            sproc_msg -info "METRIC | DOUBLE STA.TNS_MIN.MULTI_SCENARIO | $t_tns"
            sproc_msg -info "METRIC | INTEGER STA.NVP_MIN.MULTI_SCENARIO | $t_nvp"
          }

        }
      }

      ## 
      ## metrics relating to clock skew and latency
      ##

      if { $synopsys_program_name == "icc_shell" } {
        set fname "$SEV(rpt_dir)/icc.cts.report_clock_timing"
        if { ![file exists $fname] } {
          sproc_msg -info "Unable to generate clock metric unable to find file = \"$fname\"."
        } else {

          set fid [open $fname r]
          set lines [list]
          while { [gets $fid line] >= 0 } {
            lappend lines $line
          }
          close $fid

          set mode 0
          set scenario SCENARIO_NOT_SPECIFIED

          foreach line $lines {

            regexp {^Scenario\(s\):\s+(\w.*)} $line one scenario

            if { [regexp {^\s+Clock:\s+([\w]+)\s*$} $line matchVar clock_name] } {
              set name [regsub -all {\/} $clock_name {_}]
            }

            if { [regexp {^\s+Maximum setup skew:\s*$} $line ] } {
              set mode 1
            } elseif { $mode == 1 } {
              set mode 2
            } elseif { $mode == 2 } {
              regexp {\s*\S+\s+([\d\.\-]+)\s+} $line match skew
              set mode 0
              sproc_msg -info "$name : $skew"
              set metric_value [sproc_metric_format {%f} [sproc_metric_normalize -value $skew -current_unit $time_unit]]
              sproc_msg -info "METRIC | DOUBLE STA.CLK_SKEW.[sproc_clean_string -string $name.$scenario] | $metric_value"
            } elseif { [regexp {^\s+Maximum setup launch latency:\s*$} $line ]  } {
              set mode 3
            } elseif { $mode == 3 } {
              regexp {\s*\S+\s+([\d\.\-]+)\s+} $line match latency
              set mode 0
              sproc_msg -info "$name : $latency"
              set metric_value [sproc_metric_format {%f} [sproc_metric_normalize -value $latency -current_unit $time_unit]]
              sproc_msg -info "METRIC | DOUBLE STA.CLK_LATENCY_MAX.[sproc_clean_string -string $name.$scenario] | $metric_value"
            } elseif { [regexp {^\s+Minimum setup capture latency:\s*$} $line ]  } {
              set mode 4
            } elseif { $mode == 4 } {
              regexp {\s*\S+\s+([\d\.\-]+)\s+} $line match latency
              set mode 0
              sproc_msg -info "$name : $latency"
              set metric_value [sproc_metric_format {%f} [sproc_metric_normalize -value $latency -current_unit $time_unit]]
              sproc_msg -info "METRIC | DOUBLE STA.CLK_LATENCY_MIN.[sproc_clean_string -string $name.$scenario] | $metric_value"
            }
          }

        }
      }

    }

    default {
      sproc_msg -warning "sproc_metric_sta: unrecognized tool name"
    }

  }

  set xxx2 [clock seconds]
  set xxx [expr $xxx2 - $xxx1]
  sproc_msg -info "METRICS sproc_metric_sta took $xxx seconds"

  sproc_pinfo -mode stop
}

define_proc_attributes sproc_metric_sta \
  -info "Gathers timing information for metrics reporting." \
 -define_args {\
  {-scenario "The PT scenario to process." AString string optional}
}

## -----------------------------------------------------------------------------
## sproc_metric_power:
## -----------------------------------------------------------------------------

proc sproc_metric_power { args } {

  sproc_pinfo -mode start

  global env SEV SVAR TEV
  global synopsys_program_name
  global icc_standalone_reporting_flag

  if { [regexp -nocase {NONE} $TEV(report_level)] || !$SEV(metrics_enable) } {
    sproc_pinfo -mode stop
    return
  }

  set xxx1 [clock seconds]

  parse_proc_arguments -args $args options

  switch $synopsys_program_name {

    pt_shell {

      ## -------------------------------------
      ## Establishing info on units used in PT reports
      ## -------------------------------------

      ## -------------------------------------
      ## parse report_unit which has this form
      ## -------------------------------------
      ##     Voltage Units = 1 V
      ##     Capacitance Units = 1 pf
      ##     Time Units = 1 ns
      ##     Dynamic Power Units = 1 W
      ##     Leakage Power Units = 1 W
      ## -------------------------------------

      set power_unit "undefined"
      set time_unit "undefined"
      set area_unit "undefined"

      redirect -var report {
        report_power -verbose
      }

      set lines [split $report "\n"]
      foreach line $lines {
        scan $line " Time Units = %f %s" timescale time_unit
        scan $line " Leakage Power Units = %f %s" leakscale leak_units
        scan $line " Dynamic Power Units = %f %s" dynscale dyn_units
      }

      sproc_msg -info "PrimeTime reports using $time_unit for time, $leak_units for leakage, $dyn_units for dynamic"

      ## -------------------------------------
      ## DESIGN
      ## -------------------------------------

      set cell [current_design]

      set total_power        [get_attribute -quiet $cell total_power]
      set dynamic_power      [get_attribute -quiet $cell dynamic_power]
      set leakage_power      [get_attribute -quiet $cell leakage_power]
      set switching_power    [get_attribute -quiet $cell switching_power]
      set internal_power     [get_attribute -quiet $cell internal_power]
      set x_transition_power [get_attribute -quiet $cell x_transition_power]
      set glitch_power       [get_attribute -quiet $cell glitch_power]

      if { [llength $total_power]        == 0 } { set total_power NaM }
      if { [llength $dynamic_power]      == 0 } { set dynamic_power NaM }
      if { [llength $leakage_power]      == 0 } { set leakage_power NaM }
      if { [llength $switching_power]    == 0 } { set switching_power NaM }
      if { [llength $internal_power]     == 0 } { set internal_power NaM }
      if { [llength $x_transition_power] == 0 } { set x_transition_power NaM }
      if { [llength $glitch_power]       == 0 } { set glitch_power NaM }

      sproc_msg -info "METRIC | DOUBLE PWR.TOTAL.DESIGN.[sproc_clean_string -string $TEV(scenario)]     | [sproc_metric_format {%f} [sproc_metric_normalize -value $total_power -current_unit $leak_units]]"
      sproc_msg -info "METRIC | DOUBLE PWR.DYNAMIC.DESIGN.[sproc_clean_string -string $TEV(scenario)]   | [sproc_metric_format {%f} [sproc_metric_normalize -value $dynamic_power -current_unit $dyn_units]]"
      sproc_msg -info "METRIC | DOUBLE PWR.LEAKAGE.DESIGN.[sproc_clean_string -string $TEV(scenario)]   | [sproc_metric_format {%f} [sproc_metric_normalize -value $leakage_power -current_unit $leak_units]]"
      sproc_msg -info "METRIC | DOUBLE PWR.SWITCHING.DESIGN.[sproc_clean_string -string $TEV(scenario)] | [sproc_metric_format {%f} [sproc_metric_normalize -value $switching_power -current_unit $leak_units]]"
      sproc_msg -info "METRIC | DOUBLE PWR.INTERNAL.DESIGN.[sproc_clean_string -string $TEV(scenario)]  | [sproc_metric_format {%f} [sproc_metric_normalize -value $internal_power -current_unit $leak_units]]"
      sproc_msg -info "METRIC | DOUBLE PWR.XTRAN.DESIGN.[sproc_clean_string -string $TEV(scenario)]     | [sproc_metric_format {%f} [sproc_metric_normalize -value $x_transition_power -current_unit $leak_units]]"
      sproc_msg -info "METRIC | DOUBLE PWR.GLITCH.DESIGN.[sproc_clean_string -string $TEV(scenario)]    | [sproc_metric_format {%f} [sproc_metric_normalize -value $glitch_power -current_unit $leak_units]]"

      ## -------------------------------------
      ## Memory
      ## -------------------------------------

      set cells_all [get_cells -hierarchical -quiet * -filter "is_hierarchical == false"]
      set cells_to_measure [filter_collection $cells_all "is_memory_cell == true"]

      set invalid(total_power)        0
      set invalid(dynamic_power)      0
      set invalid(leakage_power)      0
      set invalid(switching_power)    0
      set invalid(internal_power)     0
      set invalid(x_transition_power) 0
      set invalid(glitch_power)       0

      set total_power        0
      set dynamic_power      0
      set leakage_power      0
      set switching_power    0
      set internal_power     0
      set x_transition_power 0
      set glitch_power       0

      foreach_in_collection cell $cells_to_measure {
        set inc_total_power        [get_attribute -quiet $cell total_power]
        set inc_dynamic_power      [get_attribute -quiet $cell dynamic_power]
        set inc_leakage_power      [get_attribute -quiet $cell leakage_power]
        set inc_switching_power    [get_attribute -quiet $cell switching_power]
        set inc_internal_power     [get_attribute -quiet $cell internal_power]
        set inc_x_transition_power [get_attribute -quiet $cell x_transition_power]
        set inc_glitch_power       [get_attribute -quiet $cell glitch_power]

        if { [llength $inc_total_power]        == 0 } {
          set invalid(total_power) 1
        } else {
          set total_power        [expr $total_power        + $inc_total_power]
        }
        if { [llength $inc_dynamic_power]      == 0 } {
          set invalid(dynamic_power) 1
        } else {
          set dynamic_power      [expr $dynamic_power      + $inc_dynamic_power]
        }
        if { [llength $inc_leakage_power]      == 0 } {
          set invalid(leakage_power) 1
        } else {
          set leakage_power      [expr $leakage_power      + $inc_leakage_power]
        }
        if { [llength $inc_switching_power]    == 0 } {
          set invalid(switching_power) 1
        } else {
          set switching_power    [expr $switching_power    + $inc_switching_power]
        }
        if { [llength $inc_internal_power]     == 0 } {
          set invalid(internal_power) 1
        } else {
          set internal_power     [expr $internal_power     + $inc_internal_power]
        }
        if { [llength $inc_x_transition_power] == 0 } {
          set invalid(x_transition_power) 1
        } else {
          set x_transition_power [expr $x_transition_power + $inc_x_transition_power]
        }
        if { [llength $inc_glitch_power]       == 0 } {
          set invalid(glitch_power) 1
        } else {
          set glitch_power       [expr $glitch_power       + $inc_glitch_power]
        }
      }

      sproc_msg -info "METRIC | DOUBLE PWR.TOTAL.MEM.[sproc_clean_string -string $TEV(scenario)]     | [sproc_metric_format {%f} [sproc_metric_normalize -value $total_power -current_unit $leak_units]]"
      sproc_msg -info "METRIC | DOUBLE PWR.DYNAMIC.MEM.[sproc_clean_string -string $TEV(scenario)]   | [sproc_metric_format {%f} [sproc_metric_normalize -value $dynamic_power -current_unit $dyn_units]]"
      sproc_msg -info "METRIC | DOUBLE PWR.LEAKAGE.MEM.[sproc_clean_string -string $TEV(scenario)]   | [sproc_metric_format {%f} [sproc_metric_normalize -value $leakage_power -current_unit $leak_units]]"
      sproc_msg -info "METRIC | DOUBLE PWR.SWITCHING.MEM.[sproc_clean_string -string $TEV(scenario)] | [sproc_metric_format {%f} [sproc_metric_normalize -value $switching_power -current_unit $leak_units]]"
      sproc_msg -info "METRIC | DOUBLE PWR.INTERNAL.MEM.[sproc_clean_string -string $TEV(scenario)]  | [sproc_metric_format {%f} [sproc_metric_normalize -value $internal_power -current_unit $leak_units]]"
      sproc_msg -info "METRIC | DOUBLE PWR.XTRAN.MEM.[sproc_clean_string -string $TEV(scenario)]     | [sproc_metric_format {%f} [sproc_metric_normalize -value $x_transition_power -current_unit $leak_units]]"
      sproc_msg -info "METRIC | DOUBLE PWR.GLITCH.MEM.[sproc_clean_string -string $TEV(scenario)]    | [sproc_metric_format {%f} [sproc_metric_normalize -value $glitch_power -current_unit $leak_units]]"

      ## -------------------------------------
      ## Clock tree
      ## -------------------------------------

      set cells_to_measure [get_clock_network_objects -type cell -include_clock_gating_network]

      set invalid(total_power)        0
      set invalid(dynamic_power)      0
      set invalid(leakage_power)      0
      set invalid(switching_power)    0
      set invalid(internal_power)     0
      set invalid(x_transition_power) 0
      set invalid(glitch_power)       0

      set total_power        0
      set dynamic_power      0
      set leakage_power      0
      set switching_power    0
      set internal_power     0
      set x_transition_power 0
      set glitch_power       0

      foreach_in_collection cell $cells_to_measure {
        set inc_total_power        [get_attribute -quiet $cell total_power]
        set inc_dynamic_power      [get_attribute -quiet $cell dynamic_power]
        set inc_leakage_power      [get_attribute -quiet $cell leakage_power]
        set inc_switching_power    [get_attribute -quiet $cell switching_power]
        set inc_internal_power     [get_attribute -quiet $cell internal_power]
        set inc_x_transition_power [get_attribute -quiet $cell x_transition_power]
        set inc_glitch_power       [get_attribute -quiet $cell glitch_power]

        if { [llength $inc_total_power]        == 0 } {
          set invalid(total_power) 1
        } else {
          set total_power        [expr $total_power        + $inc_total_power]
        }
        if { [llength $inc_dynamic_power]      == 0 } {
          set invalid(dynamic_power) 1
        } else {
          set dynamic_power      [expr $dynamic_power      + $inc_dynamic_power]
        }
        if { [llength $inc_leakage_power]      == 0 } {
          set invalid(leakage_power) 1
        } else {
          set leakage_power      [expr $leakage_power      + $inc_leakage_power]
        }
        if { [llength $inc_switching_power]    == 0 } {
          set invalid(switching_power) 1
        } else {
          set switching_power    [expr $switching_power    + $inc_switching_power]
        }
        if { [llength $inc_internal_power]     == 0 } {
          set invalid(internal_power) 1
        } else {
          set internal_power     [expr $internal_power     + $inc_internal_power]
        }
        if { [llength $inc_x_transition_power] == 0 } {
          set invalid(x_transition_power) 1
        } else {
          set x_transition_power [expr $x_transition_power + $inc_x_transition_power]
        }
        if { [llength $inc_glitch_power]       == 0 } {
          set invalid(glitch_power) 1
        } else {
          set glitch_power       [expr $glitch_power       + $inc_glitch_power]
        }
      }

      sproc_msg -info "METRIC | DOUBLE PWR.TOTAL.CLK.[sproc_clean_string -string $TEV(scenario)]     | [sproc_metric_format {%f} [sproc_metric_normalize -value $total_power -current_unit $leak_units]]"
      sproc_msg -info "METRIC | DOUBLE PWR.DYNAMIC.CLK.[sproc_clean_string -string $TEV(scenario)]   | [sproc_metric_format {%f} [sproc_metric_normalize -value $dynamic_power -current_unit $dyn_units]]"
      sproc_msg -info "METRIC | DOUBLE PWR.LEAKAGE.CLK.[sproc_clean_string -string $TEV(scenario)]   | [sproc_metric_format {%f} [sproc_metric_normalize -value $leakage_power -current_unit $leak_units]]"
      sproc_msg -info "METRIC | DOUBLE PWR.SWITCHING.CLK.[sproc_clean_string -string $TEV(scenario)] | [sproc_metric_format {%f} [sproc_metric_normalize -value $switching_power -current_unit $leak_units]]"
      sproc_msg -info "METRIC | DOUBLE PWR.INTERNAL.CLK.[sproc_clean_string -string $TEV(scenario)]  | [sproc_metric_format {%f} [sproc_metric_normalize -value $internal_power -current_unit $leak_units]]"
      sproc_msg -info "METRIC | DOUBLE PWR.XTRAN.CLK.[sproc_clean_string -string $TEV(scenario)]     | [sproc_metric_format {%f} [sproc_metric_normalize -value $x_transition_power -current_unit $leak_units]]"
      sproc_msg -info "METRIC | DOUBLE PWR.GLITCH.CLK.[sproc_clean_string -string $TEV(scenario)]    | [sproc_metric_format {%f} [sproc_metric_normalize -value $glitch_power -current_unit $leak_units]]"
    }

    de_shell -
    dc_shell -
    icc_shell {

      if { $synopsys_program_name == "icc_shell" } {
        set fname "$SEV(rpt_dir)/icc.report_power"
      } else {
        set fname "$SEV(rpt_dir)/dc.report_power"
      }
      if { ![file exists $fname] } {
        if { $SEV(metrics_flag_errors) } {
          sproc_msg -error   "sproc_metric_power: Unable to find file $fname for metric extraction."
        } else {
          sproc_msg -warning "sproc_metric_power: Unable to find file $fname for metric extraction."
        }
      } else {

        set fid [open $fname r]
        set lines [list]
        while { [gets $fid line] >= 0 } {
          lappend lines $line
        }
        close $fid

        set dyn_power MISSING
        set dyn_units MISSING
        set leak_power MISSING
        set leak_units MISSING
        set scenario SCENARIO_NOT_SPECIFIED

        foreach line $lines {
          regexp {Scenario.s.: (.*)} $line matchVar scenario
          regexp {Total Dynamic Power\s+=\s+([\-\d\.]+)\s+(\w+)} $line matchVar dyn_power dyn_units
          regexp {Cell Leakage Power\s+=\s+([\-\d\.]+)\s+(\w+)} $line matchVar leak_power leak_units

          ## DC report parsing reflected in these expressions
          regexp {Internal\s+Switching\s+Power\s+\((.*)\)\s+Leakage} $line matchVar dyn_units
          regexp {Cell\s+Power\s+\(.*\)\s+Power\s+\(.*\)\s+\(.*\)\s+Power\s+\((.+)\)\s*} $line matchVar leak_units
          regexp {Netlist Power\s+([\-\d\.\+e]+)\s+([\-\d\.\+e]+)\s+([\-\d\.\+e]+)\s+\(([\-\d\.]+).\)\s+([\-\d\.\+e]+)} $line matchVar \
            int_power     net_power     dyn_power dynamic_percent_power leak_power
          ## These strings identify the trailing end of a report package
          if {[regexp {Estimated Clock Tree} $line] || [regexp {Cell Leakage Power} $line] } {
            sproc_msg -info "METRIC | DOUBLE PWR.DYNAMIC.DESIGN.[sproc_clean_string -string $scenario] | [sproc_metric_format {%f} [sproc_metric_normalize -value $dyn_power -current_unit $dyn_units]]"
            sproc_msg -info "METRIC | DOUBLE PWR.LEAKAGE.DESIGN.[sproc_clean_string -string $scenario] | [sproc_metric_format {%f} [sproc_metric_normalize -value $leak_power -current_unit $leak_units]]"
          }
        }
      }
    }

    default {
      sproc_msg -warning "sproc_metric_power: unrecognized tool name"
    }

  }

  set xxx2 [clock seconds]
  set xxx [expr $xxx2 - $xxx1]
  sproc_msg -info "METRICS sproc_metric_power took $xxx seconds"

  sproc_pinfo -mode stop
}

define_proc_attributes sproc_metric_power \
  -info "Gathers power information for metrics reporting." \
  -define_args {
}

## -----------------------------------------------------------------------------
## sproc_metric_normalize:
## -----------------------------------------------------------------------------

proc sproc_metric_normalize { args } {

  sproc_pinfo -mode start

  ## table contains the multiplier for converting from supplied unit to normalized default
  set default_power_unit mw
  set normalize_lut(w)    1e+3
  set normalize_lut(mw)   1e+0
  set normalize_lut(uw)   1e-3
  set normalize_lut(nw)   1e-6
  set normalize_lut(pw)   1e-9

  set default_time_unit ps
  set normalize_lut(s)    1e+12
  set normalize_lut(ns)   1e+3
  set normalize_lut(ps)   1e+0

  set default_area_unit um
  set normalize_lut(nm)   1e-3
  set normalize_lut(um)   1e+0
  set normalize_lut(m)    1e+6

  set options(-value) ""
  set options(-current_unit) ""

  parse_proc_arguments -args $args options

  set val $options(-value)

  if { $val=="NaM" } {
    sproc_msg -info "Passing through special case value $val"
    sproc_pinfo -mode stop
    return $val
  }

  if { ![scan $val "%f" match] } {
    sproc_msg -error "sproc_metric_normalize cannot process value $val"
    sproc_pinfo -mode stop
    return "NaM"
  }

  if { $options(-current_unit) != "" } {
    set cur_unit [string tolower $options(-current_unit)]
    if { [array names normalize_lut -exact $cur_unit] != "" } {
      set norm_scalar $normalize_lut($cur_unit)
    } else {
      sproc_msg -error "sproc_metric_normalize not configured to convert $cur_unit"
      sproc_pinfo -mode stop
      return "NaM"
    }
  }

  set val_out [expr $val * $norm_scalar]

  sproc_pinfo -mode stop

  return $val_out

}

define_proc_attributes sproc_metric_normalize \
  -info "Used to convert metric numbers from one unit standard to another." \
  -define_args {
  {-value "value to convert" decimal string required}
  {-current_unit "Units of current value" AString string required}
}

## -----------------------------------------------------------------------------
## sproc_metric_format:
## -----------------------------------------------------------------------------

proc sproc_metric_format { format_string arg } {
  if { $arg == "NaM" } {
    return "NaM"
  } else {
    return [format $format_string $arg]
  }
}

define_proc_attributes sproc_metric_format \
  -info "Used to return NaM value or formatted value as part of metrics processing." \
  -define_args {
}

## -----------------------------------------------------------------------------
## sproc_metric_time_elapsed:
## -----------------------------------------------------------------------------

proc sproc_metric_time_elapsed { args } {

  sproc_pinfo -mode start

  set options(-start) 0
  set options(-stop) 0
  parse_proc_arguments -args $args options

  set seconds_in_day [expr 24 * 3600.0]
  set total_seconds [expr $options(-stop) - $options(-start)]
  set num_days_f [expr floor($total_seconds / $seconds_in_day)]
  set partial_day_f [expr ($total_seconds / $seconds_in_day) - $num_days_f]
  set num_days [expr int($num_days_f)]
  set partial_day [expr int($partial_day_f * $seconds_in_day)]
  set hms [clock format $partial_day -format %T -gmt true]
  set dhms [format "%02d:%s" $num_days $hms]

  sproc_pinfo -mode stop
  return "$dhms"
}

define_proc_attributes sproc_metric_time_elapsed \
  -info "Used to generate metrics related to duration of task execution." \
  -define_args {
  {-start "Indicates start time in seconds." "" int required}
  {-stop  "Indicates stop time in seconds." "" int required}
}

## -----------------------------------------------------------------------------
## sproc_metric_atpg:
## -----------------------------------------------------------------------------

proc sproc_metric_atpg { args } {

  sproc_pinfo -mode start

  global env SEV SVAR TEV

  if { ( $SEV(metrics_enable) == 0 ) } {
    sproc_pinfo -mode stop
    return
  }

  parse_proc_arguments -args $args options

  ## Set default values

  set total_faults NaM
  set test_coverage NaM
  set fault_coverage 0
  set atpg_effectiveness 0

  ## Generate and parse report

  redirect -variable report {
    report_summaries
  }

  set fault_types "Iddq Transition Path_delay Bridging Dynamic_bridging Hold_time IDDQ_bridging"

  foreach fault_type $fault_types {
    set ${fault_type}_faults "NaM"
    set ${fault_type}_coverage "NaM"
  }
  set lines [split $report "\n"]
  foreach line $lines {
    foreach fault_type $fault_types {
      regexp "$fault_type\\s+\(\[\\.\\d\]+\)\\s+\(\[\\.\\d\]+\)\\%" $line matchVar ${fault_type}_faults ${fault_type}_coverage
      regexp {total faults\s+([\d]+)} $line matchVar total_faults
      regexp {test coverage\s+([\.\d]+)\%} $line matchVar fault_coverage
    }
  }

  ## Print results

  sproc_msg -info "METRIC | INTEGER ATPG.TRANSITION.FAULTS         | $Transition_faults"
  sproc_msg -info "METRIC | DOUBLE  ATPG.TRANSITION.COVERAGE       | $Transition_coverage"
  sproc_msg -info "METRIC | INTEGER ATPG.BRIDGING.FAULTS           | $Bridging_faults"
  sproc_msg -info "METRIC | DOUBLE  ATPG.BRIDGING.COVERAGE         | $Bridging_coverage"
  sproc_msg -info "METRIC | INTEGER ATPG.HOLD_TIME.FAULTS          | $Hold_time_faults"
  sproc_msg -info "METRIC | DOUBLE  ATPG.HOLD_TIME.COVERAGE        | $Hold_time_coverage"
  sproc_msg -info "METRIC | INTEGER ATPG.IDDQ_BRIDGING.FAULTS      | $IDDQ_bridging_faults"
  sproc_msg -info "METRIC | DOUBLE  ATPG.IDDQ_BRIDGING.COVERAGE    | $IDDQ_bridging_coverage"
  sproc_msg -info "METRIC | INTEGER ATPG.IDDQ.FAULTS               | $Iddq_faults"
  sproc_msg -info "METRIC | DOUBLE  ATPG.IDDQ.COVERAGE             | $Iddq_coverage"
  sproc_msg -info "METRIC | INTEGER ATPG.PATH_DELAY.FAULTS         | $Path_delay_faults"
  sproc_msg -info "METRIC | DOUBLE  ATPG.PATH_DELAY.COVERAGE       | $Path_delay_coverage"
  sproc_msg -info "METRIC | INTEGER ATPG.DYNAMIC_BRIDGING.FAULTS   | $Dynamic_bridging_faults"
  sproc_msg -info "METRIC | DOUBLE  ATPG.DYNAMIC_BRIDGING.COVERAGE | $Dynamic_bridging_coverage"
  sproc_msg -info "METRIC | INTEGER ATPG.STUCK_AT.FAULTS   | $total_faults"
  sproc_msg -info "METRIC | DOUBLE  ATPG.STUCK_AT.COVERAGE | $fault_coverage"
  sproc_pinfo -mode stop
}

define_proc_attributes sproc_metric_atpg \
  -info "Gathers ATPG information for metrics reporting." \
  -define_args {
}

## -----------------------------------------------------------------------------
## sproc_early_complete:
## -----------------------------------------------------------------------------

proc sproc_early_complete  {} {

  sproc_pinfo -mode start

  global SEV SVAR
  global synopsys_program_name

  if { $SVAR(misc,early_complete_enable) } {

    sproc_msg -warning "Early complete enabled."

    set fname [file rootname $SEV(log_file)].early
    set fid [open $fname w]
    puts $fid "Early complete at [date]"
    close $fid

  } else {

    sproc_msg -warning "Early complete disabled."

  }

  sproc_pinfo -mode stop

}

define_proc_attributes sproc_early_complete  \
  -info "Procedure to signal early completion of task to RTM." \
  -define_args {
}


if { $SEV(project_name) != "lcrm" } {
  puts "Error: SEV(project_name) is not set to 'lcrm'. This is the expected default for most lcrm users. Change in the system environment variable editor. If you understand the impact on metric capture, edit lcrm_setup.tcl to remove this error message"
  if { $LYNX(rtm_present) } {
    exit
  }

}

## -----------------------------------------------------------------------------
## End of File
## -----------------------------------------------------------------------------

