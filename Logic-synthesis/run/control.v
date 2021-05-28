`timescale 1 ns / 1 ns
`define HLT 3'b000
`define SKZ 3'b001
`define ADD 3'b010
`define AND 3'b011
`define XOR 3'b100
`define LDA 3'b101
`define STO 3'b110
`define JMP 3'b111

module control
(
rd,
wr,
ld_ir,
ld_ac,
ld_pc,
inc_pc,
halt,
data_e,
sel,
opcode,
zero,
clk,
rst_
);

output rd;
output wr;
output ld_ir;
output ld_ac;
output ld_pc;
output inc_pc;
output halt;
output data_e;
output sel;
input  [2:0] opcode;
input  zero;
input  clk;
input  rst_;

reg rd;
reg wr;
reg ld_ir;
reg ld_ac;
reg ld_pc;
reg inc_pc;
reg halt;
reg data_e;
reg sel;
reg [2:0] nexstate;
reg [2:0] state;

always @ (posedge clk or negedge rst_)
	if(!rst_)
	state <= 3'b000;
	else
	state <= nexstate;

	always @ (state)
	case(state)
	default: begin ;end
	3'b000: begin nexstate = 3'b001;end
	3'b001: begin nexstate = 3'b011;end
	3'b011: begin nexstate = 3'b010;end
	3'b010: begin nexstate = 3'b110;end
	3'b110: begin nexstate = 3'b111;end
	3'b111: begin nexstate = 3'b101;end
	3'b101: begin nexstate = 3'b100;end
	3'b100: begin nexstate = 3'b000;end
	endcase

	always @ (opcode or state or zero)
	begin:blk
	reg alu_op;
	alu_op = opcode==`ADD || opcode==`AND || opcode==`XOR || opcode==`LDA;

	case(state)
	default:begin sel=0; rd=0; ld_ir=0; inc_pc=0; halt=0; ld_pc=0; data_e=0; ld_ac=0; wr=0;  end
	3'b001:begin sel=1; rd=0; ld_ir=0; inc_pc=0; halt=0; ld_pc=0; data_e=0; ld_ac=0; wr=0; end
	3'b011:begin sel=1; rd=1; ld_ir=0; inc_pc=0; halt=0; ld_pc=0; data_e=0; ld_ac=0; wr=0; end
	3'b010:begin sel=1; rd=1; ld_ir=1; inc_pc=0; halt=0; ld_pc=0; data_e=0; ld_ac=0; wr=0; end
	3'b110:begin sel=1; rd=1; ld_ir=1; inc_pc=0; halt=0; ld_pc=0; data_e=0; ld_ac=0; wr=0; end
	3'b111:begin sel=0; rd=0; ld_ir=0; inc_pc=1; halt=(opcode == `HLT);ld_pc=0; data_e=0; ld_ac=0;wr=0;end
	3'b101:begin sel=0; rd=alu_op; ld_ir=0; inc_pc=0; halt=0; ld_pc=0; data_e=0; ld_ac=0; wr=0; end
	3'b100:begin sel=0; rd=alu_op; ld_ir=0; halt=0; data_e=!alu_op; ld_ac=0; wr=0;inc_pc = (opcode == `SKZ)&zero;ld_pc = (opcode ==`JMP);end
	3'b000:begin sel=0; rd=alu_op; ld_ir=0; halt=0; data_e=!alu_op; ld_ac=alu_op; inc_pc=(opcode==`SKZ)&zero||(opcode==`JMP);ld_pc = (opcode == `JMP);wr = (opcode == `STO);end
	endcase
end
endmodule

