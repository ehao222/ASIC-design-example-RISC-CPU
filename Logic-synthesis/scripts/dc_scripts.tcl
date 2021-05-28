read_file -format verilog ./rtl/control.v
read_file -format verilog ./rtl/control_pad.v
write -hierarchy -f ddc -out unmapped/control_pad.ddc
list_designs
list_libs
set lib_name typical_1v2c25
current_design control_pad
link

create_clock -period 20 [get_ports clk]
set_clock_uncertainty 0.2 [get_clocks clk]

suppress_message UID-401
set_driving_cell -library $lib_name -lib_cell AND2X4 [remove_from_collection [all_inputs] [get_ports clk]]
set_input_delay 0.1 -max -clock clk [remove_from_collection [all_inputs] [get_ports clk]]

set_output_delay 1 -max -clock clk [all_outputs]
set_load [expr [load_of $lib_name/AND2X4/A] * 15] [all_outputs]

set_dont_touch i_rst true
set_dont_touch i_clk true
set_dont_touch i_zero true
set_dont_touch i_opcode_0 true
set_dont_touch i_opcode_1 true
set_dont_touch i_opcode_2 true
set_dont_touch i_sel true
set_dont_touch i_data_e true
set_dont_touch i_inc_pc true
set_dont_touch i_ld_pc true
set_dont_touch i_ld_ac true
set_dont_touch i_ld_ir true
set_dont_touch i_wr true
set_dont_touch i_rd true
set_dont_touch i_halt true
set_dont_touch_network opcode[0]
set_dont_touch_network opcode[1]
set_dont_touch_network opcode[2]

compile_ultra
report_constraint -all > ./rpt/rpt_constraints
report_timing > ./rpt/rpt_timing
report_area > ./rpt/rpt_area
report_power > ./rpt/rpt_power

write -hierarchy -format ddc -output ./mapped/control_pad.ddc
write -hierarchy -format verilog -output ./mapped/control_pad.v
write_sdc ./mapped/control_pad.sdc
write_sdf ./mapped/control_pad.sdf

list_designs
list_libs
