`timescale 1 ns / 100 ps
module counter(cnt, clk, data,rst_,load);

output[4:0] cnt;
input [4:0] data;
input clk;
input rst_;
input load;
reg [4:0] cnt;

always @(posedge clk or negedge rst_)
if(!rst_)
  cnt<=0;
else
  if(load)
     cnt<=data;
else
     cnt<=cnt+1;
endmodule
