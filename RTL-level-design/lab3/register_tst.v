`timescale 1 ns/ 1 ns
module register_tst;

wire [7:0] out;
reg [7:0] data;
reg load;
reg rst_;


register register_test(
.out(out),
.data(data),
.load(load),
.clk(clk),
.rst_(rst_)
);

clock clk1(.clk(clk));

initial 
begin
$timeformat(-9, 1, "ns",9);
$monitor("time= %t,clk= %b, data= %h,load= %b,out= %h", $stime,clk,data,load,out);
$dumpvars(2,register_test);
end



initial 
 begin
@(negedge clk) 
rst_=0;
data=0;
load=0;

@(negedge clk)
rst_=1;

@(negedge clk)
data='h55;
load=1;

@(negedge clk)
data='hAA;
load=1;
@(negedge clk)
data='hCC ;
load=0;
@(negedge clk)
$finish;

end
endmodule

