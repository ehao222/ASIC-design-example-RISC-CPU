`timescale 1 ns/1 ns
`celldefine

module mux(out ,sel,b,a);

output out;
input sel;
input b;
input a;
not (sel_,sel);
and (selb, sel,b);
and (sela, sel_,a);
or (out, selb,sela);
endmodule

`endcelldefine
