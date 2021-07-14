`timescale 1ns/100ps
module dcache (
    clock,
    reset,
    read,
    write,
    address,
    writedata,
    readdata,
    busywait,
    mem_read,
    mem_write,
    mem_address,
    mem_writedata,
    mem_readdata,
    mem_busywait
    );

 input clock, reset, read, write;
 input[7:0]      	address;
 input[7:0]     	writedata;
 input[31:0]        mem_readdata;
 input              mem_busywait;
 output reg [31:0]      mem_writedata;
 output reg mem_read, mem_write;
 output reg [5:0] mem_address;
 output reg [7:0]	readdata;
 output reg      	busywait;

 integer i;
 reg [31:0] cache_mem [7:0];               //register array to store cache blocks
 reg [4:0] v_d_tag_reg [7:0];              //register array to store valid bit, dirty bit and tag
 reg dirty, valid; 
 reg [2:0] tag, index, address_tag;
 reg [1:0] offset;

 wire hit;
 wire [7:0] muxout;                      //output of the word selecting mux
 reg  [7:0] word1, word2, word3, word4;  //registers to show the four words of the block currently indexing in the cache
  

     
  
      
    /*
    Combinational part for indexing, tag comparison for hit deciding, etc.
    ...
    ...
    */
   
    tag_cmp_hit mytaghit(tag, address_tag, valid, hit);                  //tag comparison module
    mux4x1 mymux(word1, word2 , word3, word4, muxout, offset);           //word selecting module(included #1 unit of word selecting latency)
    
   //indexing and extracting the required bits from cashe and allocating bits from address
    always @ (address,  v_d_tag_reg[address[4:2]])
    begin
        
        if((state != WRITE_HIT) || (read || write))
        begin
         address_tag = address[7:5];
         offset = address[1:0];
         index = address[4:2];
        end
        //indexing
        #1
         valid = v_d_tag_reg[address[4:2]][4];
         dirty = v_d_tag_reg[address[4:2]][3];
         tag = v_d_tag_reg[address[4:2]][2:0];
         
       
    end
     
    //this will show the current values of the block of cache according  to the index  
    always @ (tag, cache_mem[index])
    begin
         word1 = cache_mem[index][7:0];
         word2 = cache_mem[index][15:8];
         word3 = cache_mem[index][23:16];
         word4 = cache_mem[index][31:24];
    end
    
    //this block does the writing the correct word to the correct block in the cashe according to offset
    always @ (state)
    begin 
        if(state == WRITE_HIT)
          case(address[1:0])
              2'b00 : #1  cache_mem[index][7:0] = writedata;
              2'b01 : #1  cache_mem[index][15:8] = writedata;
              2'b10 : #1  cache_mem[index][23:16] = writedata;
              2'b11 : #1  cache_mem[index][31:24] = writedata;
           endcase
       
       
    end

  
   //when read or write becomes 1, then this block will make busywait to 1
   always @(posedge read, posedge write)
   begin
	busywait = 1'b1;
   end

   //this block will make busywait to 0 when state become to read hit or write hit(even the next state is also the same as previous state in hits)
   always @ (state, posedge clock)
   begin
     if(state == READ_HIT || state == WRITE_HIT)
     busywait = 0;
   end

    /* Cache Controller FSM Start */

    parameter IDLE = 3'b000, MEM_READ = 3'b001, MEM_WRITE = 3'b010, Cache_update = 3'b011, READ_HIT = 3'b100, WRITE_HIT = 3'b101;
    reg [2:0] state, next_state;

    // combinational next state logic
    always @(*)
    begin
        case (state)
            IDLE:
                if ((read || write) && !dirty && !hit)  
                    next_state = MEM_READ;

                else if((read || write) && dirty && !hit)
                    next_state = MEM_WRITE;

                else if(read && hit)
                    next_state = READ_HIT;

                else if(write && hit)
                    next_state = WRITE_HIT;

                else
                    next_state = IDLE;
            
            MEM_READ:
                if(!mem_busywait && (!(read || write)))
                    next_state = IDLE;

                else if(!mem_busywait && (read || write) && !dirty && !hit)
                    next_state = Cache_update;

                else    
                    next_state = MEM_READ;

            MEM_WRITE:
                if(!mem_busywait && (!(read || write)) && !dirty && !hit)   
                    next_state = IDLE;

                else if(!mem_busywait && (read || write) && !dirty && !hit)
                    next_state = MEM_READ;

                else
                    next_state = MEM_WRITE;

           Cache_update:
                if(read && hit)
                   next_state = READ_HIT;

                else if(write && hit)
                   next_state = WRITE_HIT;
                   
                else
                   next_state = Cache_update;

           READ_HIT :
                if(!mem_busywait && write && hit)
                   next_state = WRITE_HIT;

                else if(!mem_busywait && (!(read || write)))
                   next_state = IDLE;

                else if(!mem_busywait && (read || write) && !dirty && !hit)
                   next_state = MEM_READ;

                else if(!mem_busywait && (read || write) && dirty && !hit)
                   next_state = MEM_WRITE;

                else
                   next_state = READ_HIT;

            WRITE_HIT :
                if(!mem_busywait && read && hit)
                   next_state =READ_HIT;

                else if(!mem_busywait && (!(read || write)))
                   next_state = IDLE;

                else if(!mem_busywait && (read || write) && !dirty && !hit)
                   next_state = MEM_READ;

                else if(!mem_busywait && (read || write) && dirty && !hit)
                   next_state = MEM_WRITE;

                else
                   next_state = WRITE_HIT;

        endcase
    end

    // combinational output logic
    always @(*)
    begin
        case(state)
            IDLE:
            begin
                mem_read = 0;
                mem_write = 0;
                mem_address = 8'dx;
                mem_writedata = 8'dx;
                if(!(read || write))
                busywait = 0;
            end
         
            MEM_READ: 
            begin
                mem_read = 1;
                mem_write = 0;
                mem_address = {address_tag, index};             //sending the missing block address to memory
                mem_writedata = 32'dx;
                busywait = 1;
            end

            MEM_WRITE:
            begin
                mem_read = 0;
                mem_write = 1;
                mem_address = {tag, index};                    //sending the dirty block addresss to memory
                mem_writedata = cache_mem[index];              //sending the dirty block of data to memory
                dirty = 1'b0;
                busywait = 1; 
            end

            Cache_update:
            begin
                busywait = 1;
                #1
                v_d_tag_reg[index][4] = 1'b1;   //updating valid bit
                v_d_tag_reg[index][3] = 1'b0;   //updating dirty bit
                v_d_tag_reg[index][2:0] = address[7:5]; //updating tag
                cache_mem[index] = mem_readdata;  //writing the data block coming from the memory to the correct block in the cache
                
            end

            READ_HIT:
            begin
                mem_read = 0;
                mem_write = 0;
                mem_address = 6'dx;
                mem_writedata = 32'dx;
                readdata = muxout;                  //reading correct data from cache
            end

            WRITE_HIT:
            begin
                mem_read = 0;
                mem_write = 0;
                mem_address = 6'dx;
                mem_writedata = 32'dx;
              
         
            end
           
       

            
        endcase
    end
    
    //updating the cache when state become to write hit state
    always @(state)
    begin
       if(state == WRITE_HIT)
       begin
          v_d_tag_reg[index][3] = 1'b1; //making dirty bit to 1
          v_d_tag_reg[index][4] = 1'b1; //making valid bit to 1
       end
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
            cache_mem[i] = 32'd0;
            v_d_tag_reg[i] = 5'd0;
          end
          busywait = 0;
    end

    /* Cache Controller FSM End */

endmodule