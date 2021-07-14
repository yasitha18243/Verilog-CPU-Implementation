`timescale 1ns/100ps
module signedex_and_shift(in, out);

input [7:0] in;                 //input which should be signextended and shift
output reg [31:0] out;          //output the signextended and shifted value

reg [31:0] tmp2;

always @ (in)
 begin
  tmp2 = {{24{in[7]}}, in};     //sign extending
  out = tmp2 << 2;              //shifting
 end



endmodule