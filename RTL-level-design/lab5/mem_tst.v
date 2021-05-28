
`timescale 1 ns/ 1 ns
module mem_tst;

reg read;
reg write;
reg [4:0] addr;
reg [7:0] dreg;
wire [7:0] data = (!read)?dreg:8'hZ;
integer i;


mem m1 ( .data(data), .addr(addr), .read(read), .write(write));



initial
begin
$timeformat (-9, 1, " ns",9);
$display ("  TIME   ADDR  WR RD  DATA  ");
$display ("------- ------ -- -- --------");
$monitor ("%t %b %b %b %b", $time, addr, write, read, data );
$dumpvars(2, mem_tst);
end


task write_val;
input [4:0] addr;
input [7:0] data;
begin
mem_tst.addr = addr;
mem_tst.dreg = data;
#1 write = 1;
#1 write = 0;
end
endtask



task read_val;
input [4:0] addr;
input [7:0] data;
begin
mem_tst.addr = addr;
mem_tst.read = 1;
#1 if(mem_tst.data !==data)
begin
$display ("At time %t and addr %b, data is %b and should be %b", 
$time, addr, mem_tst.data, data);
$display("TEST FAILED");
$finish;
end
#1 read = 0;
end
endtask



initial begin

write = 0;
read = 0;


for (i=0; i<=31; i=i+1)
write_val(i,i);


for(i=0; i<=31; i=i+1)
read_val(i,i);
$display("TEST PASSED");
$finish;
end
endmodule


