module CacheCounter (
    input reset,
    input clk,

    input is_hit,
    input is_input_valid,
    input [31:0] pc,

    output reg [31:0] memory_accesses,
    output reg [31:0] hits
);
  reg [31:0] last_pc, last_pc_next, next_memory_accesses, next_hits;
  always @(*) begin
    if (last_pc != pc && is_input_valid) begin
      next_memory_accesses = memory_accesses + 1;
      if (is_hit) next_hits = hits + 1;
      else next_hits = hits;
      last_pc_next = pc;
    end else begin
      next_memory_accesses = memory_accesses;
      next_hits = hits;
      last_pc_next = last_pc;
    end
  end

  always @(posedge clk) begin
    if (reset) begin
      memory_accesses <= 0;
      hits <= 0;
      last_pc <= 32'hffffffff;
    end else begin
      memory_accesses <= next_memory_accesses;
      hits <= next_hits;
      last_pc <= last_pc_next;
    end
  end
endmodule
