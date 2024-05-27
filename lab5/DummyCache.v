`include "CLOG2.v"
`include "dummy_cache_def.v"

module DummyCache #(
    parameter LINE_SIZE = 16
) (
    input reset,
    input clk,

    input is_input_valid,
    input [31:0] addr,
    input mem_rw,
    input [31:0] din,

    output reg is_ready,
    output reg is_output_valid,
    output reg [31:0] dout,
    output reg is_hit
);
  reg data_mem_is_input_valid, data_mem_read, data_mem_write;
  reg [LINE_SIZE * 8 - 1:0] data_mem_din;
  wire data_mem_is_output_valid, data_mem_ready;
  wire [LINE_SIZE * 8 - 1:0] data_mem_dout;
  DataMemory #(
      .BLOCK_SIZE(LINE_SIZE)
  ) data_mem (
      .reset(reset),
      .clk  (clk),

      .is_input_valid(is_input_valid),
      .addr(addr >> (`CLOG2(LINE_SIZE))),  // NOTE: address must be shifted by CLOG2(LINE_SIZE)
      .mem_read(data_mem_read),
      .mem_write(data_mem_write),
      .din(data_mem_din),

      // is output from the data memory valid?
      .is_output_valid(data_mem_is_output_valid),
      .dout(data_mem_dout),
      // is data memory ready to accept request?
      .mem_ready(data_mem_ready)
  );

  reg [(`CLOG2((LINE_SIZE >> 2))) - 1:0] block_offset;
  reg [LINE_SIZE * 8 - 1:0] memory_block, next_memory_block, temp_block;
  reg [1:0] state, next_state;
  reg current_read;

  always @(*) begin
    block_offset = addr[(`CLOG2((LINE_SIZE>>2)))+1:2];
    is_hit = 1;

    case (state)
      `DUMMY_CACHE_STANDBY: begin
        if (is_input_valid) begin
          if (mem_rw) begin
            next_state = `DUMMY_CACHE_WRITE_READ;
          end else begin
            next_state = `DUMMY_CACHE_READ;
          end
          data_mem_read = 1;
          data_mem_is_input_valid = 1;
        end else begin
          next_state = `DUMMY_CACHE_STANDBY;
          data_mem_read = 0;
          data_mem_is_input_valid = 0;
        end
        data_mem_write = 0;
        next_memory_block = {(LINE_SIZE * 8) {1'b0}};
        is_output_valid = 0;
      end
      `DUMMY_CACHE_READ: begin
        if (data_mem_is_output_valid) begin
          next_state = `DUMMY_CACHE_STANDBY;
          data_mem_read = 0;
          data_mem_write = 0;
          data_mem_is_input_valid = 0;
          is_output_valid = 1;
        end else begin
          next_state = `DUMMY_CACHE_READ;
          data_mem_read = 0;
          data_mem_write = 0;
          data_mem_is_input_valid = 0;
          is_output_valid = 0;
        end
        next_memory_block = data_mem_dout;
      end
      `DUMMY_CACHE_WRITE_READ: begin
        if (data_mem_is_output_valid) begin
          next_state = `DUMMY_CACHE_WRITE_WRITE;
          data_mem_read = 0;
          data_mem_write = 1;
          data_mem_is_input_valid = 1;
        end else begin
          next_state = `DUMMY_CACHE_WRITE_READ;
          data_mem_read = 1;
          data_mem_write = 0;
          data_mem_is_input_valid = 1;
        end
        next_memory_block = (data_mem_dout & ~({{(LINE_SIZE*8-32){1'b0}},32'hffffffff} << (32 * block_offset))) | ({{(LINE_SIZE*8-32){1'b0}},din} << (32 * block_offset));
        is_output_valid = 0;
      end
      `DUMMY_CACHE_WRITE_WRITE: begin
        if (data_mem_ready) begin
          next_state = `DUMMY_CACHE_STANDBY;
          data_mem_write = 0;
          data_mem_is_input_valid = 0;
        end else begin
          next_state = `DUMMY_CACHE_WRITE_WRITE;
          data_mem_write = 1;
          data_mem_is_input_valid = 1;
        end
        data_mem_read = 0;
        next_memory_block = memory_block;
        is_output_valid = 0;
      end
      default: begin
        next_state = 0;
        data_mem_read = 0;
        data_mem_write = 0;
        data_mem_is_input_valid = 0;
        next_memory_block = 0;
        is_output_valid = 0;
      end
    endcase

    data_mem_din = next_memory_block;
    temp_block = next_memory_block >> (32 * block_offset);
    dout = temp_block[31:0];
    is_ready = next_state == `DUMMY_CACHE_STANDBY;
  end

  always @(posedge clk) begin
    if (reset) begin
      state <= `DUMMY_CACHE_STANDBY;
      memory_block <= {(LINE_SIZE * 8) {1'b0}};
    end else begin
      state <= next_state;
      memory_block <= next_memory_block;
    end
  end
endmodule
