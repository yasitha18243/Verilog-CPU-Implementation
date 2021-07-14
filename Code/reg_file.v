
`timescale 1ns/100ps
module reg_file(IN, OUT1, OUT2, INADDRESS, OUT1ADDRESS, OUT2ADDRESS, WRITE, CLK, RESET, BUSYWAIT);

    input [2:0] OUT1ADDRESS, OUT2ADDRESS;                               //3 bit inputs to give register address
    input [2:0] INADDRESS;                                              // 3 bit input to give address to write
    input [7:0] IN;                                                     // the value to write is stored in this input
    input CLK, RESET, WRITE, BUSYWAIT;                                          

    output reg [7:0] OUT1, OUT2;                                        //two outputs to output the register values

    reg [7:0] Register[7:0];                                            // making 8 registers which have 8 bits
    
    integer j;                                                          //integer to count in for loop
   
  always @ (posedge CLK)                                    //this is senitive to positive clock edge(this block is for write to register)                 

   begin
        if(WRITE && ~RESET)
         begin
           #1
           if(!BUSYWAIT)
             Register[INADDRESS] <= IN;                       //writing IN data to the register if it is not in Reset state at the positive clock edge
         end
        
       
   end
 

  always @ (OUT1ADDRESS, OUT2ADDRESS, INADDRESS, posedge RESET)    
    begin
     
    if(RESET)                            //checking whether if RESET is 1 , if 1 then do the resetting
          #2
          begin
            for(j = 0; j < 8; j=j+1)
            begin
               Register[j] = 8'b0;        //making the values in register to 00000000
               
            end
         end

      //this part is always occur if changes happen in OUTADDRESSES 
      #2
      OUT1 <= Register[OUT1ADDRESS];
      OUT2 <= Register[OUT2ADDRESS]; 
   
          
        
    end

  




endmodule




