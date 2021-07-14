`timescale 1ns/100ps
module AND(in0, in1, out);
  input in0, in1;             //two inputs that should do the and operation
  output reg out;             //output of the operation

always @ (in0, in1)           //this block will work if changes hapennd to in0 and in1
 begin
    out = in0 & in1;
 end
 
  
endmodule