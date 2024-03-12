module data_memory #(parameter MEM_DEPTH = 16384) (input reset,
                                                   input clk,
                                                   input [31:0] addr,    // address of the data memory
                                                   input [31:0] din,     // data to be written
                                                   input mem_read,       // is read signal driven?
                                                   input mem_write,      // is write signal driven?
                                                   output [31:0] dout);  // output of the data memory at addr
  integer i;
  // Data memory
  reg [31:0] mem[0: MEM_DEPTH - 1];
  // Do not touch dmem_addr
  wire [13:0] dmem_addr;
  assign dmem_addr = addr[15:2];
  // Do not touch or use _unused_ok
  wire _unused_ok = &{1'b0,
                  addr[31:16],
                  addr[1:0],
                  1'b0};

  // TODO
  // Asynchrnously read data from the memory
  // Synchronously write data to the memory
  // (use dmem_addr to access memory)

  // Initialize data memory (do not touch)
  always @(posedge clk) begin
    if (reset) begin
      for (i = 0; i < MEM_DEPTH; i = i + 1)
        // DO NOT TOUCH COMMENT BELOW
        /* verilator lint_off BLKSEQ */
        mem[i] = 32'b0;
        /* verilator lint_on BLKSEQ */
        // DO NOT TOUCH COMMENT ABOVE
    end
  end
endmodule


