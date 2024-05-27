// Do not submit this file.
`include "cpu.v"

module top (
    input reset,
    input clk,
    output is_halted,
    output [31:0] print_reg[0:31],
    output [31:0] memory_accesses,
    output [31:0] hits
);

  cpu cpu (
      .reset(reset),
      .clk(clk),
      .is_halted(is_halted),
      .print_reg(print_reg),
      .memory_accesses(memory_accesses),
      .hits(hits)
  );

endmodule
