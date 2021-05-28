`timescale 1 ns/1 ns
`celldefine

module dffr(q,q_,d,clk,rst_);

output q;
output q_;
input d;
input clk;
input rst_;

nand n1(de,dl,qe);
nand n2(qe,clk,de,rst_);
nand n3(dl,d,dl_,rst_);
nand n4(dl_,dl,clk,qe);
nand n5(q,qe,q_);
nand n6(q_,dl_,q,rst_);

endmodule
`endcelldefine
