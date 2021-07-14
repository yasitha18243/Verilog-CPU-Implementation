   `timescale 1ns/100ps
module icache(
    clock,
    PC,
    reset,
    busywait,
    instruction,
    mem_read,
    mem_busywait,
    mem_address,
    mem_ins_block
);

input clock, reset;
input [31:0] PC;
input mem_busywait;
input [127:0] mem_ins_block;        //instruction block which read from memory
output reg [5:0] mem_address;
output reg mem_read;
output reg [31:0] instruction;
output reg busywait;

reg [127:0] icache_mem [7:0];      //register array for instruction cache memory block
reg [3:0] v_tag_reg [7:0];         //register array to store valid bit and tag
reg [9:0] address;                 //register to store 10 bit address from PC
reg [2:0] address_tag, tag, index;
reg valid;
reg [1:0] offset;
reg [31:0] ins1, ins2, ins3, ins4;

reg hit;                          
wire [31:0] muxout;

integer i;

//wires to do tag comparison and hit
wire w1, w2, w3;
wire r1, r2, r3;

 //tag comparison and hit
   xnor xn1(w1, tag[0], address_tag[0]);        //xnor operations
   xnor xn2(w2, tag[1], address_tag[1]);
   xnor xn3(w3, tag[2], address_tag[2]);

   and an1(r1, w1, w2);                            //and operations
   and an2(r2, r1, w3);
   and an3(r3, r2, valid);

   always @ (r3, muxout)
   begin
    #1
    hit = r3;
   end   

    mux4x1_ins mymux_ins(ins1, ins2 , ins3, ins4, muxout, offset);           //word selecting module(included #1 unit of word selecting latency)
    
   //indexing and extracting the required bits from cashe and allocating bits from address
   always @ (address,  v_tag_reg[address[6:4]])
    begin
         address_tag = address[9:7];
         offset = address[3:2];
         index = address[6:4];

        //indexing
        #1
         valid = v_tag_reg[address[6:4]][3];
         tag = v_tag_reg[address[6:4]][2:0];
         
       
    end

    //this block will make busywait to 1 when PC changes and reset the value of hit
    always @ (PC)
    begin
       if(!reset)
       begin
       address = PC[9:0];
       hit = 0;
       busywait = 1'b1;
       end
    end

  
     
    //this will show the current instructions of the block of instruction cache according  to the index  
    always @ (tag, icache_mem[index])
    begin
         ins1 = icache_mem[index][31:0];
         ins2 = icache_mem[index][63:32];
         ins3 = icache_mem[index][95:64];
         ins4 = icache_mem[index][127:96];
    end
    
   //this block will make busywait to 0 when the clock edge comes in the READ_HIT state
   always @ (posedge clock)
   begin
     if(state == READ_HIT)
     busywait = 0;
   end

 
    /* Cache Controller FSM Start */

    parameter IDLE = 3'b000, MEM_READ = 3'b001, Cache_update = 3'b010, READ_HIT = 3'b011;
    reg [2:0] state, next_state;

    // combinational next state logic
    always @(*)
    begin
        case (state)
            IDLE:
                if (!hit)  
                    next_state = MEM_READ;

                else
                    next_state = IDLE;
                
            
            MEM_READ:
                if(!mem_busywait && !hit)
                    next_state = Cache_update;

                else
                    next_state =  MEM_READ;   


           Cache_update:
                if(hit)
                   next_state = READ_HIT;
            
                else
                   next_state = Cache_update;

           READ_HIT:
                if(!hit)
                   next_state = MEM_READ;
                else
                   next_state = READ_HIT;


        endcase
    end

    //this block changes the state according to the change of hit
    always @ (hit)
    begin
        if(hit)
         state = READ_HIT;
        else
         state = IDLE;
    end
    
    //this block changes the current state to IDLE when new PC value comes
    always @(tag, index)
    begin
       if(state == READ_HIT)
          state = IDLE;
    end

    //this block will send the correct word of instruction block to the instruction 
    always @ (state)
    begin
      if(state == READ_HIT)
        begin
          mem_read = 0;
          mem_address = 6'dx;
          instruction = muxout;
        end
    end

    // combinational output logic
    always @(*)
    begin
        case(state)
            IDLE:
            begin
                mem_read = 0;
                mem_address = 6'dx;
               
            end

            MEM_READ: 
            begin
                mem_read = 1;
                mem_address = {address_tag, index};
                busywait = 1;
            end

           
            Cache_update:
            begin
    
                busywait = 1;
                #1
                v_tag_reg[index][3] = 1'b1;   //updating valid bit
                v_tag_reg[index][2:0] = address[9:7]; //updating tag
                icache_mem[index] = mem_ins_block;  //writing the data block coming from the memory to the correct block in the cache
                
            end
           
            
        endcase
    end

    

    // sequential logic for state transitioning 
    always @(posedge clock, reset)
    begin
        if(reset)
            state = IDLE;
        else
            state = next_state;
    end
    
    //resetting block
    always @ (posedge reset)
    begin
        if(reset)
          for(i = 0; i < 8; i++)
          begin
            icache_mem[i] = 128'd0;
            v_tag_reg[i] = 4'd0;
          end
          busywait = 0;
    end

    /* Cache Controller FSM End */
endmodule