`timescale 1ns/100ps
module cpu(PC, INSTRUCTION, CLK, RESET, READ_MEM, WRITE_MEM, ADDRESS, WRITEDATA, READDATA, BUSYWAIT, BUSYWAIT_INS);

input CLK, RESET;  //declaring input , output ports
input [31:0] INSTRUCTION;
input  BUSYWAIT, BUSYWAIT_INS;
input [7:0] READDATA;
output [31:0] PC;
output READ_MEM, WRITE_MEM;
output [7:0] WRITEDATA, ADDRESS;


wire Con_compliment, Con_immediate, Con_jump, Con_beq, WRITE, ZERO, andout, orout, READ_MEM, WRITE_MEM, BUSYWAIT, ALU_RDATA_SELECT, BUSYWAIT_INS;                //declaring wires to connect modules
wire [2:0] INADDRESS, OUT1ADDRESS, OUT2ADDRESS, AluOp; 
wire [7:0] IN, OUT1, OUT2, CMP_OUT, Immediate_val, OFFSET, RESULT, mux1_out, mux2_out, READDATA, mux_aluResult_ReadData_out;
wire [31:0] Extend_shift_out;      //this is the wire to connect signextended and shifted value

assign ADDRESS = RESULT;   //connecting the wires 
assign WRITEDATA = OUT1;

//instantiating modules 
Pro_counter myPc(PC, CLK, RESET, orout, Extend_shift_out, BUSYWAIT, BUSYWAIT_INS);
Control_Unit myCU(INSTRUCTION, AluOp, Con_compliment, Con_immediate, Immediate_val, Con_jump, Con_beq, INADDRESS, OUT1ADDRESS, OUT2ADDRESS, WRITE, OFFSET,  READ_MEM, WRITE_MEM, ALU_RDATA_SELECT);
reg_file myRegFile1(mux_aluResult_ReadData_out, OUT1, OUT2, INADDRESS, OUT1ADDRESS, OUT2ADDRESS, WRITE, CLK, RESET, BUSYWAIT);
mux aluResult_ReadData_SELECT(RESULT, READDATA,  ALU_RDATA_SELECT, mux_aluResult_ReadData_out);  //this is the mux to select, readdata or alu result
signedex_and_shift mySignShift(OFFSET, Extend_shift_out);                //sign extending and shift module
complement mycmp(OUT2, CMP_OUT);                                         //complement module
mux mymux1(OUT2, CMP_OUT, Con_compliment, mux1_out);                    //this mux is to choose operand2 value or complement of operand2 value
mux mymux2(Immediate_val, mux1_out, Con_immediate, mux2_out);           //this mux is used to choose output of mux1 or immediate value from the instruction
alu myalu(OUT1, mux2_out, RESULT, AluOp, ZERO);
AND myand(ZERO, Con_beq, andout);                                       //this AND will output 1 if the instruction is beq and two operands are equal 
OR myor(andout, Con_jump, orout);                                       //this OR will output 1, if beq or j instruction should be done and should add signextend value to PC+4

endmodule