module non_blocking(clk, a, b, c);

	output [3:0] b, c;
	input  [3:0] a;
	input        clk;
	reg    [3:0] b, c;
	always @(posedge clk)
	begin
		b <= a;
		c <= b;
		$display ("Non_Blocking: a = %d, b = %d, c = %d. ", a, b, c);
	end
endmodule
