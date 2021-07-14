`timescale 1ns/100ps
module complement(in, out);

 input [7:0] in;          //input value that should be complemented
 output reg [7:0] out;    //this will output the compliment of the input

 reg [7:0] tmp;           //tempory register to store bitwise complement

always @ (in)
begin
  #1
  tmp = ~in;               //doing bitwise complement

  out = tmp + 8'b00000001; //adding 1 to tmp value to do 2's complement
end

endmodule

