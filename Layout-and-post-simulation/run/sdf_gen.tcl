set link_library "/home1/lib/smic/SP013D3_V1p4/syn/SP013D3_V1p2_typ.db /home1/lib/smic/aci/sc-x/synopsys/typical_1v2c25.db"
read_verilog ../output/control_pad_final.v
current_design control_pad
read_db /home1/lib/smic/aci/sc-x/synopsys/typical_1v2c25.db
read_db /home1/lib/smic/SP013D3_V1p4/syn/SP013D3_V1p2_typ.db
read_parasitics -pin_cap_included ../output/control_pad.spef
write_sdf ../output/control_pad.sdf

