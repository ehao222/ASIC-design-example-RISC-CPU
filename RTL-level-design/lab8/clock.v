/*********
 * CLOCK *
 *********/

`timescale 1 ns / 1 ns

`define period 10

module clkgen
	(
	clk
	);

output clk;
reg    clk;

  initial
    begin
      clk = 1;
      forever
        begin
          #(`period/2) clk = 0;
          #(`period/2) clk = 1;
        end
    end

endmodule

