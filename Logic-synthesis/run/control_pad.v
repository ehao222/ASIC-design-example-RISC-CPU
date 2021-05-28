
module control_pad ( rst_, clk, zero, opcode, rd, wr, ld_ir, ld_ac, ld_pc, 
        inc_pc, halt, data_e, sel );
  input [2:0] opcode;
  input rst_, clk, zero;
  output rd, wr, ld_ir, ld_ac, ld_pc, inc_pc, halt, data_e, sel;
  wire   rd_pad, wr_pad, ld_ac_pad, ld_pc_pad, inc_pc_pad, halt_pad,
         data_e_pad, sel_pad, zero_pad, clk_pad, rst_pad, \i_control/N21 ,
         \i_control/N14 , \i_control/state[2] , n1, n2, n3, n4, n5, n7, n8, n9,
         n11, n12, n14, n15, n16, n17, n18, n19, n20;
  wire   [2:0] opcode_pad;

  PI i_rst ( .PAD(rst_), .C(rst_pad) );
  PI i_clk ( .PAD(clk), .C(clk_pad) );
  PI i_zero ( .PAD(zero), .C(zero_pad) );
  PI i_opcode_0 ( .PAD(opcode[0]), .C(opcode_pad[0]) );
  PI i_opcode_1 ( .PAD(opcode[1]), .C(opcode_pad[1]) );
  PI i_opcode_2 ( .PAD(opcode[2]), .C(opcode_pad[2]) );
  PO8 i_rd ( .I(rd_pad), .PAD(rd) );
  PO8 i_wr ( .I(wr_pad), .PAD(wr) );
  PO8 i_ld_ir ( .I(n2), .PAD(ld_ir) );
  PO8 i_ld_ac ( .I(ld_ac_pad), .PAD(ld_ac) );
  PO8 i_ld_pc ( .I(ld_pc_pad), .PAD(ld_pc) );
  PO8 i_inc_pc ( .I(inc_pc_pad), .PAD(inc_pc) );
  PO8 i_halt ( .I(halt_pad), .PAD(halt) );
  PO8 i_data_e ( .I(data_e_pad), .PAD(data_e) );
  PO8 i_sel ( .I(sel_pad), .PAD(sel) );
  DFFRX1 \i_control/state_reg[2]  ( .D(\i_control/N14 ), .CK(clk_pad), .RN(
        rst_pad), .Q(\i_control/state[2] ), .QN(n19) );
  DFFRXL \i_control/state_reg[1]  ( .D(sel_pad), .CK(clk_pad), .RN(rst_pad), 
        .Q(n18), .QN(n4) );
  DFFRX1 \i_control/state_reg[0]  ( .D(\i_control/N21 ), .CK(clk_pad), .RN(
        rst_pad), .QN(n3) );
  NOR2XL U3 ( .A(opcode_pad[0]), .B(n5), .Y(wr_pad) );
  NOR2XL U20 ( .A(n8), .B(n9), .Y(data_e_pad) );
  AND2XL U8 ( .A(n11), .B(n8), .Y(ld_ac_pad) );
  NOR3BXL U17 ( .AN(n14), .B(opcode_pad[0]), .C(n12), .Y(halt_pad) );
  INVX1 U1 ( .A(opcode_pad[0]), .Y(n1) );
  NOR2X1 U19 ( .A(opcode_pad[1]), .B(opcode_pad[2]), .Y(n14) );
  NAND3X1 U11 ( .A(n11), .B(opcode_pad[1]), .C(opcode_pad[2]), .Y(n5) );
  AOI2BB2X1 U23 ( .B0(opcode_pad[1]), .B1(opcode_pad[2]), .A0N(opcode_pad[1]), 
        .A1N(opcode_pad[2]), .Y(n8) );
  NOR2BX2 U24 ( .AN(n9), .B(n20), .Y(sel_pad) );
  CLKINVX1 U25 ( .A(n7), .Y(n2) );
  NAND4BX1 U26 ( .AN(n9), .B(zero_pad), .C(opcode_pad[0]), .D(n14), .Y(n15) );
  OAI211X1 U27 ( .A0(n5), .A1(n1), .B0(n12), .C0(n15), .Y(inc_pc_pad) );
  NAND3XL U28 ( .A(opcode_pad[0]), .B(opcode_pad[2]), .C(opcode_pad[1]), .Y(
        n16) );
  NOR2X1 U29 ( .A(n9), .B(n16), .Y(ld_pc_pad) );
  OAI211X1 U30 ( .A0(n3), .A1(\i_control/state[2] ), .B0(n8), .C0(n4), .Y(n17)
         );
  OAI211X1 U31 ( .A0(\i_control/state[2] ), .A1(n4), .B0(n7), .C0(n17), .Y(
        rd_pad) );
  NOR2X1 U32 ( .A(\i_control/state[2] ), .B(n9), .Y(n11) );
  NAND2X1 U33 ( .A(n20), .B(n18), .Y(n12) );
  NAND2BXL U34 ( .AN(n20), .B(n7), .Y(\i_control/N14 ) );
  NAND2XL U35 ( .A(n3), .B(n18), .Y(n7) );
  NOR2XL U36 ( .A(n3), .B(n19), .Y(n20) );
  NAND2XL U37 ( .A(n4), .B(n3), .Y(n9) );
  OAI22XL U38 ( .A0(n4), .A1(n19), .B0(n18), .B1(\i_control/state[2] ), .Y(
        \i_control/N21 ) );
endmodule

