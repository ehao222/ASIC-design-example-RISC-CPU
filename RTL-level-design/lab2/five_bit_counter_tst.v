`timescale 1 ns/ 1 ns

module five_bit_counter_tst;
wire [4:0] cnt;
reg [4:0] data;
reg rst_;
reg load;
reg clk;

counter c1
(
.cnt(cnt),
.clk(clk),
.data(data),
.rst_(rst_),
.load(load)
);

initial begin
clk=0;
forever begin
 #10 clk =1'b1;
 #10 clk =1'b0;
end
end

initial
begin
  $timeformat(-9,1,"ns",9);
  $monitor("time=%t ,data=%h,clk=%b, rst_= %b,load=%b,cnt=%b",$stime,data,clk,rst_,load,cnt);
 $dumpvars(2,five_bit_counter_tst);
end

task expect;

input [4:0] expects;
if(cnt!==expects) 
begin
  $display("At time %t cnt is %b and should be %b",$time,cnt,expects);
  $display("TEST FAILED");
  $finish;
end 
endtask

initial
begin 

@(negedge clk)

{rst_,load,data}=7'b0_X_XXXXX;@(negedge clk) expect(5'h00);

{rst_,load,data}=7'b1_1_11101;@(negedge clk) expect(5'h1D);

{rst_,load,data}=7'b1_0_11101;
repeat(5)@(negedge clk);
expect(5'h02);

{rst_,load,data}=7'b1_1_11111;@(negedge clk) expect(5'h1F);

{rst_,load,data}=7'b0_X_XXXXX;@(negedge clk) expect(5'h00);
$display("TEST PASSED");
$finish;
end
endmodule




