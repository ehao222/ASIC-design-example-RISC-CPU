`define width 8
`timescale 1 ns/ 1 ns 
module mux_tst;

reg [`width:1] a,b;
wire [`width:1] out;
reg sel;


mux #(`width) m1 (.out(out),.sel(sel),.b(b),.a(a));

initial
begin
   $monitor($stime ,,"sel=%b ,a=%b,b=%b, out=%b",sel,a,b,out);
$dumpvars(2,mux_tst);	

   sel=0;b={`width{1'b0}};a={`width{1'b1}};
#5 sel=0; b={`width{1'b1}};a={`width{1'b0}};
#5 sel=1; b={`width{1'b0}};a={`width{1'b1}};
#5 sel=1; b={`width{1'b1}};a={`width{1'b0}};
#5 $finish;
end
endmodule
