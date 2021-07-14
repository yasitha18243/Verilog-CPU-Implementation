`timescale 1ns/100ps
module pro_tb();
    reg CLK, RESET;
    wire [31:0] PC;
    wire [31:0] INSTRUCTION;


    wire READ_MEM, WRITE_MEM, BUSYWAIT_MEM;//busywait for data memory
    wire [5:0] ADDRESS_MEM; 
    wire [31:0] WRITEDATA_MEM, READDATA_MEM;

    wire READ_CACHE, WRITE_CACHE, BUSYWAIT_CACHE;//busywait for data cache memory
    wire [7:0] ADDRESS_CACHE, WRITEDATA_CACHE, READDATA_CASHE;

    wire BUSYWAIT_INS_CACHE, BUSYWAIT_INS_MEM;          //busywaits for instruction memories
    wire READ_INS_MEM;
    wire [5:0] ADDRESS_INS_MEM;
    wire [127:0] MEM_INS_BLOCKREAD;


    
    
    /* 
    -----
     CPU
    -----
    */
    icache inscachemem(CLK, PC, RESET,  BUSYWAIT_INS_CACHE, INSTRUCTION, READ_INS_MEM, BUSYWAIT_INS_MEM, ADDRESS_INS_MEM, MEM_INS_BLOCKREAD);
    imem_for_icache imem(CLK,  READ_INS_MEM, ADDRESS_INS_MEM, MEM_INS_BLOCKREAD, BUSYWAIT_INS_MEM);     
    dcache dcashemem(CLK, RESET, READ_CACHE, WRITE_CACHE, ADDRESS_CACHE, WRITEDATA_CACHE, READDATA_CASHE, BUSYWAIT_CACHE, READ_MEM, WRITE_MEM, ADDRESS_MEM, WRITEDATA_MEM, READDATA_MEM, BUSYWAIT_MEM);
    dmem_for_dcache dmem(CLK, RESET, READ_MEM, WRITE_MEM, ADDRESS_MEM, WRITEDATA_MEM, READDATA_MEM, BUSYWAIT_MEM);  //connecting data memory to testbench
    cpu mycpu(PC, INSTRUCTION, CLK, RESET, READ_CACHE, WRITE_CACHE, ADDRESS_CACHE, WRITEDATA_CACHE, READDATA_CASHE, BUSYWAIT_CACHE, BUSYWAIT_INS_CACHE);

    initial
    begin
    
        // generate files needed to plot the waveform using GTKWave
        $dumpfile("cpu_wavedata.vcd");
		$dumpvars(0, pro_tb);
        
        CLK = 1'b0;
        RESET = 1'b0;
        
        // TODO: Reset the CPU (by giving a pulse to RESET signal) to start the program execution
        #1
        RESET = 1'b1;

        #8
        RESET = 1'b0;
        
        // finish simulation after some time
        #4500
        $finish;
        
    end
    
    // clock signal generation
    always
        #4 CLK = ~CLK;
        

endmodule