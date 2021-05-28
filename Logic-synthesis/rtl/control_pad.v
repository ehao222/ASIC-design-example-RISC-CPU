`timescale 1ns/1ns
module control_pad
(
    input wire rst_,
    input wire clk,
    input wire zero,
    input wire [2:0] opcode,
    output wire rd,
    output wire wr,
    output wire ld_ir,
    output wire ld_ac,
    output wire ld_pc,
    output wire inc_pc,
    output wire halt,
    output wire data_e,
    output wire sel
);

wire rd_pad;
wire wr_pad;
wire ld_ir_pad;
wire ld_ac_pad;
wire ld_pc_pad;
wire inc_pc_pad;
wire halt_pad;
wire data_e_pad;
wire sel_pad;
wire [2:0] opcode_pad;
wire zero_pad;
wire clk_pad;
wire rst_pad;
PI i_rst(.PAD(rst_),.C(rst_pad));
PI i_clk(.PAD(clk),.C(clk_pad));
PI i_zero(.PAD(zero),.C(zero_pad));
PI i_opcode_0(.PAD(opcode[0]),.C(opcode_pad[0]));
PI i_opcode_1(.PAD(opcode[1]),.C(opcode_pad[1]));
PI i_opcode_2(.PAD(opcode[2]),.C(opcode_pad[2]));

PO8 i_rd(.I(rd_pad),.PAD(rd));
PO8 i_wr(.I(wr_pad),.PAD(wr));
PO8 i_ld_ir(.I(ld_ir_pad),.PAD(ld_ir));
PO8 i_ld_ac(.I(ld_ac_pad),.PAD(ld_ac));
PO8 i_ld_pc(.I(ld_pc_pad),.PAD(ld_pc));
PO8 i_inc_pc(.I(inc_pc_pad),.PAD(inc_pc));
PO8 i_halt(.I(halt_pad),.PAD(halt));
PO8 i_data_e(.I(data_e_pad),.PAD(data_e));
PO8 i_sel(.I(sel_pad),.PAD(sel));

control i_control
(
.rst_(rst_pad),
.clk(clk_pad),
.rd(rd_pad),
.wr(wr_pad),
.ld_ir(ld_ir_pad),
.ld_ac(ld_ac_pad),
.ld_pc(ld_pc_pad),
.inc_pc(inc_pc_pad),
.halt(halt_pad),
.data_e(data_e_pad),
.sel(sel_pad),
.opcode(opcode_pad),
.zero(zero_pad)
);

endmodule





