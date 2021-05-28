/*******
 * CPU *
 *******/

`timescale 1 ns / 1 ns

module cpu
	(
	rst_
	);

input rst_;

  wire [7:0] data	;
  wire [7:0] alu_out	;
  wire [7:0] ir_out	;
  wire [7:0] ac_out	;
  wire [4:0] pc_addr	;
  wire [4:0] ir_addr	;
  wire [4:0] addr	;
  wire [2:0] opcode	;

  assign opcode  = ir_out[7:5];
  assign ir_addr = ir_out[4:0];


//Instantiate design components 

  control      ctl1
	(
	.rd	(rd		),
	.wr	(wr		),
	.ld_ir	(ld_ir		),
	.ld_ac	(ld_ac		),
	.ld_pc	(ld_pc		),
	.inc_pc	(inc_pc		),
	.halt	(halt		),
	.data_e	(data_e		),
	.sel	(sel		),
	.opcode	(opcode		),
	.zero	(zero		),
	.clk	(clock		),
	.rst_	(rst_		)
	);

  alu          alu1
	(
	.out	(alu_out	),
	.zero	(zero		),
	.opcode	(opcode		),
	.data	(data		),
	.accum	(ac_out		)
	);

  register     ac
	(
	.out	(ac_out		),
	.data	(alu_out	),
	.load	(ld_ac		),
	.clk	(clock		),
	.rst_	(rst_		)
	);

  register     ir
	(
	.out	(ir_out		),
	.data	(data		),
	.load	(ld_ir		),
	.clk	(clock		),
	.rst_	(rst_		)
	);

  mux #5 smx
	(
	.out	(addr		),
	.sel	(sel		),
	.b	(pc_addr	),
	.a	(ir_addr	)
	);

  mem          mem1
	(
	.data	(data		),
	.addr	(addr		),
	.read	(rd		),
	.write	(wr		)
	);

  counter      pc
	(
	.cnt	(pc_addr	),
	.data	(ir_addr	),
	.load	(ld_pc		),
	.clk	(inc_pc		),
	.rst_	(rst_		)
	);

  clkgen       clk
	(
	.clk	(clock		)
	);

//Glue logic
  assign data = (data_e) ? alu_out: 8'bz;

endmodule

