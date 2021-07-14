  `timescale 1ns/100ps
  module Control_Unit(INSTRUCTION, AluOp, Con_compliment, Con_immediate, Immediate_val, Con_jump, Con_beq, INADDRESS, OUT1ADDRESS, OUT2ADDRESS, WRITE, OFFSET, READ_MEM, WRITE_MEM,  ALU_RDATA_SELECT);

   input [31:0] INSTRUCTION;                                //32 bit instruction array
   output reg [2:0] INADDRESS, OUT1ADDRESS, OUT2ADDRESS;    //addresses to send to register file
   output reg [7:0] Immediate_val, OFFSET;                          //reg to output  immediate value from the INSTRUCTION
   output reg Con_compliment, Con_immediate, Con_jump, Con_beq, WRITE,  READ_MEM,  WRITE_MEM, ALU_RDATA_SELECT;         //control signal outputs in the control unit
   output reg [2:0] AluOp;                                 //control signal for alu

  always @ (INSTRUCTION)
    begin

    //instruction decoding
      
       INADDRESS = INSTRUCTION[18:16];
       OUT1ADDRESS = INSTRUCTION[10:8];
       OUT2ADDRESS = INSTRUCTION[2:0];
       Immediate_val = INSTRUCTION[7:0];
       OFFSET = INSTRUCTION[23:16];                       //whenever the operation is j or beq, then this OFFSET is used

       READ_MEM = 1'b0;                            //read signal of the data memory(making sure that busywait is generated even in consecutive read memory instructions)
       WRITE_MEM = 1'b0;                           //write signal of the data memory(making sure that busywait is generated even in consecutive write memory instructions)
    
    //other all the opertaions have below control signals except loadi , sub, j and beq 
    //this means if complement signal is 0 then mux1 outputs normal output from the register
    //and if immediate signal is 1 then mux2 outputs the output from mux1, not the immediate value
    //control signals generated after #1 latency
       #1
       Con_immediate = 1'b1;
       Con_compliment = 1'b0;
       Con_jump = 1'b0;
       Con_beq = 1'b0;
      
    //generating control signals according to opcode
    
       case (INSTRUCTION[31:24])

          8'b00000000 : begin
                            Con_immediate = 1'b0;               //changing control signals to output immediate value from mux2
                            WRITE = 1'b1;                       //loadi 
                            AluOp = 3'b000;
                            ALU_RDATA_SELECT = 1'b0;           //control signal to select Alu result for IN
                        end

          8'b00000001 : begin
                            WRITE = 1'b1;                      //mov operation
                            AluOp = 3'b000;
                            ALU_RDATA_SELECT = 1'b0;           //control signal to select Alu result for IN
                        end

          8'b00000010 : begin                                  //add operation
                            WRITE = 1'b1;
                            AluOp = 3'b001;
                            ALU_RDATA_SELECT = 1'b0;           //control signal to select Alu result for IN
                        end

          8'b00000011 : begin                                  //sub operation
                            
                            Con_compliment = 1'b1;                  //changing control signal to output complement from mux1
                            WRITE = 1'b1;
                            AluOp = 3'b001;
                            ALU_RDATA_SELECT = 1'b0;           //control signal to select Alu result for IN
                        end 

          8'b00000100 : begin                                  //and operation
                            AluOp = 3'b010;
                            WRITE = 1'b1;
                            ALU_RDATA_SELECT = 1'b0;          //control signal to select Alu result for IN
                        end                                                        

          8'b00000101 : begin                                //or operation
                            AluOp = 3'b011;
                            WRITE = 1'b1;
                            ALU_RDATA_SELECT = 1'b0;         //control signal to select Alu result for IN
                        end 
                          
          8'b00000110 : begin                                //j operation 
                           Con_jump = 1'b1;
                           WRITE = 1'b0;
                        end

          8'b00000111 : begin                                //beq operation  
                           Con_beq = 1'b1;                   //both Con_beq and Con_compliment signals will be 1 in this operation
                           WRITE = 1'b0;
                           AluOp = 3'b001;
                           Con_compliment = 1'b1;
                        end  

          8'b00001000 : begin                                //lwd
                           READ_MEM = 1'b1;
                           AluOp = 3'b00;
                           ALU_RDATA_SELECT = 1'b1;          //selecting read data for the IN value
                           WRITE = 1'b1;
                          
                        end  

          8'b00001001 : begin                               //lwi
                           READ_MEM = 1'b1;
                           Con_immediate = 1'b0;
                           AluOp = 3'b00;
                           ALU_RDATA_SELECT = 1'b1;         //selecting read data for the IN value
                           WRITE = 1'b1;
                        end 

          8'b00001010 : begin                              //swd
                           WRITE_MEM = 1'b1;
                           AluOp = 3'b00;
                           WRITE = 1'b0;
                        end 

          8'b00001011 : begin                              //swi
                           WRITE_MEM = 1'b1;
                           Con_immediate = 1'b0;
                           AluOp = 3'b00;
                           WRITE = 1'b0;
                       end                                     
          

       endcase  
     
    end

endmodule