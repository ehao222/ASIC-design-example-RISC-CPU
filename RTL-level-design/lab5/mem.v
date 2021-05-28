`timescale 1ns/ 1ns

module mem( data, addr, read, write);

input [7:0] data;
input [4:0] addr;
input read;
input write;
reg [7:0] memory [0:31];

//assign addr_out = addr[4]*(2^4)+addr[3]*(2^3)+addr[2]*(2^2)+addr[1]*(2^1)+addr[0];
assign data = (read) ? memory[addr]:{8'bzzzzzzzz};

always @(posedge write)
begin
memory[addr] <= data[7:0];
end

endmodule
