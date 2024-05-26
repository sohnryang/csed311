module Cache #(parameter LINE_SIZE = 16,
               parameter NUM_SETS = `CACHE_SET_COUNT,
               parameter NUM_WAYS = `CACHE_WAY_COUNT) (
    input reset,
    input clk,

    input is_input_valid,
    input [31:0] addr,
    input mem_rw,
    input [31:0] din,

    output is_ready,
    output is_output_valid,
    output [31:0] dout,
    output is_hit);
  // Wire declarations
  wire is_data_mem_ready;
  wire signal_memory_read;
  wire signal_memory_write;
  // Reg declarations
  reg [3:0] cache_state;
  // You might need registers to keep the status.

  // Instantiate data memory
  DataMemory #(.BLOCK_SIZE(LINE_SIZE)) data_mem(
    .reset(reset),
    .clk(clk),

    .is_input_valid(is_input_valid),
    .addr(addr << `CLOG2(LINE_SIZE)),        // NOTE: address must be shifted by CLOG2(LINE_SIZE)
    .mem_read(signal_memory_read),
    .mem_write(signal_memory_write),
    .din(din),

    // is output from the data memory valid?
    .is_output_valid(is_output_valid),
    .dout(dout),
    // is data memory ready to accept request?
    .mem_ready(is_data_mem_ready)
  );

  // ---------- Generating Cache set * `CACHE_SET_COUNT ----------
  wire cache_input_valid_of_set   [0: NUM_SETS - 1];
  wire cache_hit_of_set           [0: NUM_SETS - 1];
  wire cache_output_valid_of_set  [0: NUM_SETS - 1];
  wire [31:0] cache_data_of_set   [0: NUM_SETS - 1];

  generate
    integer i = 0;
    for (i = 0; i < NUM_SETS; i = i + 1) begin
      CacheSet cache_set(
        .clk(clk),
        .rst(reset),
        
        .addr(addr),
        .din(din),
        .is_input_valid(cache_input_valid_of_set[i]),
        
        .hit(cache_hit_of_set[i]),
        .dout(cache_data_of_set[i]),
        .is_output_valid(cache_valid_of_set[i])
      );
    end
  endgenerate

  // ---------- Combinational Search from cache ----------
  always @(*) begin
    if (mem_rw == 0) begin
      is_hit <= cache_hit_of_set[0] | cache_hit_of_set[1] | cache_hit_of_set[2] | cache_hit_of_set[3];
      dout <= cache_data_of_set[0] | cache_data_of_set[1] | cache_data_of_set[2] | cache_hit_of_set[3];
      is_ready <= 1;
    end
  end 
endmodule
