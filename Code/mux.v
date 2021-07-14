`timescale 1ns/100ps
module mux(in0, in1, sel, out);

input [7:0] in0, in1;          //ports to input data to multiplexer
input sel;                     //selecting port of the multiplexer
output reg [7:0] out;

always @ (in0, in1, sel)       //this will run always when changes happen in in0, in1, sel
 begin
   if(sel == 1'b0)
      out = in0;
   else
      out = in1;
 end

endmodule