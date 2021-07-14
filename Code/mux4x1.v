`timescale 1ns/100ps
module mux4x1(in0, in1, in2, in3, out, sel);

input [7:0] in0, in1, in2, in3;
input [1:0] sel;
output reg [7:0] out;

always @ (in0, in1, in2, in3, sel)
begin
   case(sel)
       2'b00 : #1 out = in0;
       2'b01 : #1 out = in1;
       2'b10 : #1 out = in2;
       2'b11 : #1 out = in3;
   endcase
end
  
endmodule