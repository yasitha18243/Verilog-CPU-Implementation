# Verilog-CPU-Implementation
This is a CPU implementation done by using verilog which includes instruction memory and data memory with their cache memories. Several instructions can be executed in this CPU.

How to Run,

1.Compile

   iverilog -o cpu.vvp cpu.v pro_tb.v alu.v mux.v Control_Unit.v Pro_counter.v complement.v reg_file.v AND.v OR.v signedex_and_shift.v dmem_for_dcache.v dcache.v tag_cmp_hit.v mux4x1.v icache.v  mux4x1_ins.v imem_for_icache.v


2. Run

   vvp cpu.vvp

3.Open with gtkwave tool

  gtkwave cpu_wavedata.vcd
