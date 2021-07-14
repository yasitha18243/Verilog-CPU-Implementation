`timescale 1ns/100ps
module Pro_counter(PC, CLK, RESET, JumpBeq, JumpBeq_Value, BUSYWAIT, BUSYWAIT_INS);


 input CLK, RESET, BUSYWAIT, JumpBeq, BUSYWAIT_INS;               //in this JumpBeq will be 1, when the operation is j or beq
 input [31:0] JumpBeq_Value;             //sign extended and shifted input value
 output reg [31:0] PC;
 reg [31:0] tmp1_pc = 0;                 //tempory register to store incremented value of PC
 reg [31:0] tmp2_pc = 0;                 //tempory register to store the addition of sign extended and shifted value

//in this always block if PC is updated then after #2 PC increment happens parallely to instruction fetching which is constructed in the testbench
 always @ (PC)
  begin
    #1 tmp1_pc = PC + 4;                       //normal PC increment
    #2 tmp2_pc = tmp1_pc + JumpBeq_Value;      //this is the addition of signed extended and shifted value for PC+4
                                               //this will work parrallely to ALU
  end

//this block is used to update tmp2_pc when relavant jump or beq is a instruction miss in instruction cache(in these cases after instruction came then the correct jump value comes. Not after the #2 from PC update )
  always @ (JumpBeq_Value)
  begin
    #2 tmp2_pc = tmp1_pc + JumpBeq_Value;
  end

//in this always block PC will update on a positive clock edge if RESET = 0
 always @ (posedge CLK)
  begin
     if(~RESET)
      begin
        #1
       if(!BUSYWAIT && !BUSYWAIT_INS)
        begin
         if(JumpBeq)                            //if the operation is j or beq, then this PC update will happen
            PC = tmp2_pc;
         else                                  //this update will happen in every other operation, not in j or beq
            PC = tmp1_pc;
        end
          
      end
  end

//this block does the ressetting of the PC
  always @ (posedge RESET)
   begin
    #1
    PC = -4;                    //whenever RESET become 1, PC is updated to -4
   end                        
endmodule