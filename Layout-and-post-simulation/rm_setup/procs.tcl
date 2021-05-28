# Synopsys Customer Education Services
# IC Compiler Workshop series
#
# Tcl procedures to simplify life...

puts "\#\#\# Processing procs.tcl..."

create_command_group CES_procs
set TOOLS_VIEW_PATH "../../../ref/tools"

# Get command results/reports in separate graphical tk window
# This expects view.tk to be in the path, which is the other half
# of this procedure!
# Examples: view man compile,  view report_timing -max_paths 20
#======================================================
#Compatibility with VCS/DVE:
if {[info exists uclidir]} {
        set view_proc_name tview
        alias v tview
} else {
        set view_proc_name view
        alias v view
}
proc $view_proc_name {args} {
        global TOOLS_VIEW_PATH
        set VIEW_COMMAND $TOOLS_VIEW_PATH/view.tk
        if {$args == ""} {
                puts "Please provide a command."
                return
        }

        if { [catch {open "| $VIEW_COMMAND \"$args\"" w} PIPE] } {
                return "Can't open pipe for '$VIEW_COMMAND'"
        }
        redirect -channel $PIPE {uplevel $args}
        flush $PIPE
}
if {$view_proc_name == "view"} {
        define_proc_attributes $view_proc_name \
        -info "Display output of any command in a separate Tk window." \
        -command_group CES_procs \
        -define_args { {args "Command with arguments" args} }
}

proc qor {name} {
        file mkdir reports
        create_qor_snapshot -name $name
        redirect -file reports/$name.qor_snapshot.rpt {report_qor_snapshot -no_display}
}

# Generates statistics on the current session:
# Rev 1.0
# amins@synopsys.com
proc host_stats {} {
        redirect -variable cated {exec cat /proc/cpuinfo}
        set cated [split $cated "\n"]
        foreach l $cated {
                regexp {^model name\s*\:\s+(.+)$} $l m cpu_model
                regexp {^cpu MHz\s*\:\s+(.+)$} $l m cpu_mhz
                regexp {^cache size\s*\:\s+(\d+)} $l m cache_size
                regexp {^processor\s*\:\s+(\d+)} $l m num_cores
        }
        incr num_cores

        redirect -variable cated {exec cat /proc/meminfo}
        set cated [split $cated "\n"]
        foreach l $cated {
                regexp {^MemTotal\s*\:\s+(\d+)} $l m mem_total
                regexp {^MemFree\s*\:\s+(\d+)} $l m mem_free
        }
        set mem_total [format "%-6.2f" [expr $mem_total / 1024.0 / 1024.0]]
        set mem_free  [format "%-6.2f" [expr $mem_free  / 1024.0 / 1024.0]]

        puts "####################################################"
        puts "##### Session information:"
        puts ""
        puts "    Date:              [date]"
        puts "    hostname:          [exec hostname]"
        puts "    uname -a:          [exec uname -a]"
        puts "    CPU model:         $cpu_model"
        puts "    CPU MHz:           $cpu_mhz"
        puts "    CPU cache:         $cache_size"
        puts "    Number of cores:   $num_cores"
        puts "    Total memory:      $mem_total GB"
        puts "    Free memory:       $mem_free GB"
        puts "    bin path:          $::bin_path"
        puts ""
        puts "####################################################"
}
define_proc_attributes host_stats \
        -info "Display statistics of the current host (server)" \
        -command_group CES_procs


proc gui {} {
        uplevel {
                if {$in_gui_session == false} {
                        gui_start
                } else {
                        gui_stop
                        echo "... or just 'gui'"
                }
        }
}
define_proc_attributes gui \
        -info "Start or stop the GUI" \
        -command_group CES_procs

alias vman "view man"


#
# Always Ask
# This useful procedure is on solvnet, Doc Id  012959
#
proc aa {args} {

        parse_proc_arguments -args $args results

        echo "*********  Commands **********"
        help *$results(pattern)*

        echo "********* Variables **********"
        uplevel "printvar *$results(pattern)*"

        if {[info exists results(-verbose)]} {
                echo "********* -help *************"
                apropos *$results(pattern)*
        }
}; # end proc

define_proc_attributes aa -info "always ask - Searches Synopsys help for both commands and variables" \
        -command_group CES_procs \
        -define_args {
                {pattern "Pattern to search for" pattern string required}
                {-verbose "Search -help as well" "" boolean optional}
        }


#echo "The following procedures are defined for use in this workshop."
#echo "They are NOT standard IC Compiler commands."
help CES_procs


# Define a few useful aliases for the class
alias cs change_selection
alias csa "change_selection -add"
alias rt "report_timing -capacitance -transition_time -significant_digits 3"
alias rts {report_timing -capacitance -transition_time -significant_digits 3 -scenarios [all_active_scenarios]}
alias rc "report_constraint -all"
alias rcs {report_constraint -all -scenarios [all_active_scenarios]}
alias h history
alias ac all_connected
alias fo "all_fanout -from"
alias fi "all_fanin -to"

history keep 100

set gui_online_browser "firefox"

