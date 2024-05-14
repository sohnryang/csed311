module Cache #(parameter LINE_SIZE = 16,
               parameter NUM_SETS = /* Your choice */
               parameter NUM_WAYS = /* Your choice */) (
    input reset,
    input clk,

    input is_input_valid,
    input [31:0] addr,
    input mem_read,
    input mem_write,
    input [31:0] din,

    output is_ready,
    output is_output_valid,
    output [31:0] dout,
    output is_hit);
  // Wire declarations
  wire is_data_mem_ready;
  // Reg declarations
  // You might need registers to keep the status.

  assign is_ready = is_data_mem_ready;

  // Instantiate data memory
  DataMemory #(.BLOCK_SIZE(LINE_SIZE)) data_mem(
    .reset(reset),
    .clk(clk),

    .is_input_valid(),
    .addr(),        // NOTE: address must be shifted by CLOG2(LINE_SIZE)
    .mem_read(),
    .mem_write(),
    .din(),

    // is output from the data memory valid?
    .is_output_valid(),
    .dout(),
    // is data memory ready to accept request?
    .mem_ready(is_data_mem_ready)
  );
endmodule
