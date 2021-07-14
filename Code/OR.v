`timescale 1ns/100ps
module OR (in0, in1, out);
 input in0, in1;            //two inputs which should be done Or operation
 output reg out;            //output of the Or operation

 always @ (in0, in1)        //this block will work if changes happened to in0 and in1
   out = in0 | in1;
   
endmodule