`timescale 1ns / 100ps
module compareTop;

wire [3:0] b1,c1,b2,c2;
reg [3:0] a;
reg clk;

initial
begin
clk=0;
forever #50 clk= ~ clk;
end

initial
$dumpvars (2, compareTop);

initial

begin
  a = 4'h3;
$display ("__________________________");
# 100 a = 4'h7;
$display ("__________________________");
# 100 a = 4'hf;
$display ("__________________________");
# 100 a = 4'ha;
$display ("__________________________");
# 100 a = 4'h2;
$display ("__________________________");
# 100 $display ("__________________________");
$finish;
end
non_blocking non_blocking(clk,a,b2,c2);
blocking blocking(clk, a, b1, c1);

endmodule


