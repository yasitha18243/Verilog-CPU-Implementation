`timescale 1ns/100ps

module alu(DATA1, DATA2, RESULT, SELECT, ZERO); //alu module

   input [7:0] DATA1, DATA2;             //declaring multiple bits inputs
   input [2:0] SELECT;                   //alu operation selector
   output wire ZERO;                     //output to know whether the RESULT is equal to 0
   output reg [7:0] RESULT;             //declaring output
   
 

   always @ (DATA1, DATA2, SELECT)      //when DATA values or SELECT values are changed then this should be run again(sensitive inputs for always block)

    begin
    
                            
      case (SELECT)                                        //selecting the operation and making the result according to it
          3'b000 : #1 RESULT = DATA2;                     //FORWARD function when SELECT = 000
          3'b001 : #2 RESULT = DATA1 + DATA2;             //ADD function when SELECT = 001
          3'b010 : #1 RESULT = DATA1 & DATA2;             //bitwise AND function when SELECT = 010
          3'b011 : #1 RESULT = DATA1 | DATA2;                //bitwise OR funtion when SELECT = 011
         
      endcase
    end 


    always @ (DATA1, DATA2, SELECT)
    begin
       #1
       case(SELECT)
           
          3'b100 : begin                                  //logical shift left(sll)
                      
                      case(DATA2)
                         8'd0 :  RESULT = DATA1;
                         8'd1 :  RESULT = {DATA1[6:0], 1'b0};
                         8'd2 :  RESULT = {DATA1[5:0], 2'b00};
                         8'd3 :  RESULT = {DATA1[4:0], 3'b000};
                         8'd4 :  RESULT = {DATA1[3:0], 4'b0000};
                         8'd5 :  RESULT = {DATA1[2:0], 5'b00000};
                         8'd6 :  RESULT = {DATA1[1:0], 6'b000000};
                         8'd7 :  RESULT = {DATA1[0], 7'b0000000};
                         default :  RESULT = 8'b00000000;
                      endcase
                   end

          3'b101 : begin                                     //logical shift right(srl)
                      case(DATA2)
                         8'd0 :  RESULT = DATA1;
                         8'd1 :  RESULT = {1'b0, DATA1[7:1]};
                         8'd2 :  RESULT = {2'b00, DATA1[7:2]};
                         8'd3 :  RESULT = {3'b000, DATA1[7:3]};
                         8'd4 :  RESULT = {4'b0000, DATA1[7:4]};
                         8'd5 :  RESULT = {5'b00000, DATA1[7:5]};
                         8'd6 :  RESULT = {6'b000000, DATA1[7:6]};
                         8'd7 :  RESULT = {7'b0000000, DATA1[7]};
                         default :  RESULT = 8'b00000000;
                      endcase
                   end

          3'b110  : begin                                                //arithmetic shift right(sra)
                      case(DATA2)
                         8'd0 :  RESULT = DATA1;
                         8'd1 :  RESULT = {DATA1[7], DATA1[7:1]};
                         8'd2 :  RESULT = {{2{DATA1[7]}}, DATA1[7:2]};
                         8'd3 :  RESULT = {{3{DATA1[7]}}, DATA1[7:3]};
                         8'd4 :  RESULT = {{4{DATA1[7]}}, DATA1[7:4]};
                         8'd5 :  RESULT = {{5{DATA1[7]}}, DATA1[7:5]};
                         8'd6 :  RESULT = {{6{DATA1[7]}}, DATA1[7:6]};
                         8'd7:   RESULT = {{7{DATA1[7]}}, DATA1[7]};
                         default :  RESULT = {8{DATA1[7]}};
                      endcase
                    end
                                                                          //ror (rotating right)
          3'b111  : begin                                                //for this there are only 8 different results no matter how many times rotated including same value 
                        case(DATA2[2:0])                                 //that should be rotated, because DATA2 has 8 bits.
                         3'd0 :  RESULT = DATA1;                        //and also if number of rotation is a mutiple of 8, result also will be the same value that should be rotated
                         3'd1 :  RESULT = {DATA1[0], DATA1[7:1]};       //So only by selecting last three bits of DATA2 we can have all the combinations wich relavant to the number of rotations should be done
                         3'd2 :  RESULT = {DATA1[1], DATA1[0], DATA1[7:2]};
                         3'd3 :  RESULT = {DATA1[2], DATA1[1], DATA1[0], DATA1[7:3]};
                         3'd4 :  RESULT = {DATA1[3], DATA1[2], DATA1[1], DATA1[0], DATA1[7:4]};
                         3'd5 :  RESULT = {DATA1[4], DATA1[3], DATA1[2], DATA1[1], DATA1[0], DATA1[7:5]};
                         3'd6 :  RESULT = {DATA1[5], DATA1[4], DATA1[3], DATA1[2], DATA1[1], DATA1[0], DATA1[7:6]};
                         3'd7:   RESULT = {DATA1[6], DATA1[5], DATA1[4], DATA1[3], DATA1[2], DATA1[1], DATA1[0], DATA1[7]};
                        endcase
                                                                         

                    end
         endcase
    end
    nor mynor(ZERO, RESULT[0], RESULT[1], RESULT[2], RESULT[3], RESULT[4], RESULT[5], RESULT[6], RESULT[7]);        //ZERO outputs 0 whenever RESULT !=0, whenever RESULT = 0, ZERO will output 1
    


endmodule
