`timescale 1 ns/ 1 ns

module register(out, data, load, clk, rst_);

output [7:0] out;
input [7:0] data;
input load;
input clk;
input rst_;

wire [7:0] out;
wire [7:0] l1,l2;


mux mux7(.out(l1[7]), .sel(load), .b(data[7]), .a(l2[7]) );
dffr dffr7(.q(l2[7]),.d(l1[7]), .clk(clk), .rst_(rst_));

mux mux6(.out(l1[6]), .sel(load), .b(data[6]), .a(l2[6]) );
dffr dffr6(.q(l2[6]),.d(l1[6]), .clk(clk), .rst_(rst_));

mux mux5(.out(l1[5]), .sel(load), .b(data[5]), .a(l2[5]) );
dffr dffr5(.q(l2[5]),.d(l1[5]), .clk(clk), .rst_(rst_));

mux mux4(.out(l1[4]), .sel(load), .b(data[4]), .a(l2[4]) );
dffr dffr4(.q(l2[4]), .d(l1[4]), .clk(clk), .rst_(rst_));

mux mux3(.out(l1[3]), .sel(load), .b(data[3]), .a(l2[3]) );
dffr dffr3(.q(l2[3]), .d(l1[3]), .clk(clk), .rst_(rst_));

mux mux2(.out(l1[2]), .sel(load), .b(data[2]), .a(l2[2]) );
dffr dffr2(.q(l2[2]), .d(l1[2]), .clk(clk), .rst_(rst_));

mux mux1(.out(l1[1]), .sel(load), .b(data[1]), .a(l2[1]) );
dffr dffr1(.q(l2[1]), .d(l1[1]), .clk(clk), .rst_(rst_));

mux mux0(.out(l1[0]), .sel(load), .b(data[0]), .a(l2[0]) );
dffr dffr0(.q(l2[0]), .d(l1[0]), .clk(clk), .rst_(rst_));

assign out =l2;

endmodule

