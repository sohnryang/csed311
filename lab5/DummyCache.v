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
  reg data_mem_is_input_valid, data_mem_read, data_mem_write, data_mem_read_called;
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

  reg [25:0] tag_of_addr;
  reg [1:0] idx_of_addr;
  reg [(`CLOG2((LINE_SIZE >> 2))) - 1:0] block_offset_of_addr;
  reg [LINE_SIZE * 8 - 1:0] memory_block, next_memory_block, temp_block;
  reg [1:0] state, next_state;
  reg current_read;


  // ---------- Cache Definitions ----------
  /*
      3         2         1         0
    [10987654321098765432109876543210]
          TAG 26 bit           IIBBGG
  */
  reg [25:0] set_0_tag_table [0:3];
  reg [127:0] set_0_data_table [0:3];
  reg set_0_valid_table [0:3];
  reg set_0_dirty_table [0:3];

  reg [25:0] set_1_tag_table [0:3];
  reg [127:0] set_1_data_table [0:3];
  reg set_1_valid_table [0:3];
  reg set_1_dirty_table [0:3];

  reg [25:0] set_2_tag_table [0:3];
  reg [127:0] set_2_data_table [0:3];
  reg set_2_valid_table [0:3];
  reg set_2_dirty_table [0:3];

  reg [25:0] set_3_tag_table [0:3];
  reg [127:0] set_3_data_table [0:3];
  reg set_3_valid_table [0:3];
  reg set_3_dirty_table [0:3];

  reg [3:0] idx_0_lru_table;
  reg [3:0] idx_1_lru_table;
  reg [3:0] idx_2_lru_table;
  reg [3:0] idx_3_lru_table;
  
  always @(*) begin
    tag_of_addr = addr[31:6];
    idx_of_addr = addr[5:4];
    block_offset_of_addr = addr[(`CLOG2((LINE_SIZE>>2)))+1:2];    

    case (state)
      `DUMMY_CACHE_STANDBY: begin
        if (is_input_valid) begin
          if (mem_rw) begin
            next_state = `DUMMY_CACHE_WRITE_READ;
          end else begin
            next_state = `DUMMY_CACHE_READ;
          end
        end else begin
          next_state = `DUMMY_CACHE_STANDBY;
        end
        data_mem_read = 0;
        data_mem_read_called = 0;
        data_mem_is_input_valid = 0;
        data_mem_write = 0;
        next_memory_block = {(LINE_SIZE * 8) {1'b0}};
        is_output_valid = 0;
        is_hit = 0;
      end
      `DUMMY_CACHE_READ: begin
        if (set_0_tag_table[idx_of_addr] == tag_of_addr && set_0_valid_table[idx_of_addr] == 1'b1) begin
          next_memory_block = set_0_data_table[idx_of_addr];
          next_state = `DUMMY_CACHE_STANDBY;
          data_mem_read = 0;
          data_mem_read_called = 0;
          data_mem_write = 0;
          data_mem_is_input_valid = 0;
          is_output_valid = 1;
          is_hit = 1;
        end else if (set_1_tag_table[idx_of_addr] == tag_of_addr && set_1_valid_table[idx_of_addr] == 1'b1) begin
          next_memory_block = set_1_data_table[idx_of_addr];
          next_state = `DUMMY_CACHE_STANDBY;
          data_mem_read = 0;
          data_mem_read_called = 0;
          data_mem_write = 0;
          data_mem_is_input_valid = 0;
          is_output_valid = 1;
          is_hit = 1;
        end else if (set_2_tag_table[idx_of_addr] == tag_of_addr && set_2_valid_table[idx_of_addr] == 1'b1) begin
          next_memory_block = set_2_data_table[idx_of_addr];
          next_state = `DUMMY_CACHE_STANDBY;
          data_mem_read = 0;
          data_mem_read_called = 0;
          data_mem_write = 0;
          data_mem_is_input_valid = 0;
          is_output_valid = 1;
          is_hit = 1;
        end else if (set_3_tag_table[idx_of_addr] == tag_of_addr && set_3_valid_table[idx_of_addr] == 1'b1) begin
          next_memory_block = set_3_data_table[idx_of_addr];
          next_state = `DUMMY_CACHE_STANDBY;
          data_mem_read = 0;
          data_mem_read_called = 0;
          data_mem_write = 0;
          data_mem_is_input_valid = 0;
          is_output_valid = 1;
          is_hit = 1;
        end else begin
          next_memory_block = data_mem_dout;
          if (data_mem_is_output_valid) begin
            next_state = `DUMMY_CACHE_STANDBY;
            data_mem_read = 0;
            data_mem_read_called = 0;
            data_mem_write = 0;
            data_mem_is_input_valid = 0;
            is_output_valid = 1;
            is_hit = 1;
            data_mem_read_called = 0;
          end else if (data_mem_read_called) begin
            next_state = `DUMMY_CACHE_READ;
            data_mem_read = 0;
            data_mem_read_called = 0;
            data_mem_write = 0;
            data_mem_is_input_valid = 0;
            is_output_valid = 0;
            is_hit = 0;
          end else begin
            next_state = `DUMMY_CACHE_READ;
            data_mem_read = 1;
            data_mem_read_called = 1;
            data_mem_write = 0;
            data_mem_is_input_valid = 1;
            is_output_valid = 0;
            is_hit = 0;
          end
        end
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
        next_memory_block = (data_mem_dout & ~({{(LINE_SIZE*8-32){1'b0}},32'hffffffff} << (32 * block_offset_of_addr))) | ({{(LINE_SIZE*8-32){1'b0}},din} << (32 * block_offset_of_addr));
        is_output_valid = 0;
        is_hit = 0;
        data_mem_read_called = 0;
      end
      `DUMMY_CACHE_WRITE_WRITE: begin
        if (data_mem_ready) begin
          next_state = `DUMMY_CACHE_STANDBY;
          data_mem_write = 0;
          data_mem_is_input_valid = 0;
          is_hit = 1;
        end else begin
          next_state = `DUMMY_CACHE_WRITE_WRITE;
          data_mem_write = 1;
          data_mem_is_input_valid = 1;
          is_hit = 0;
        end
        data_mem_read = 0;
        next_memory_block = memory_block;
        is_output_valid = 0;
        data_mem_read_called = 0;
      end
    endcase

    data_mem_din = next_memory_block;
    temp_block = next_memory_block >> (32 * block_offset_of_addr);
    dout = temp_block[31:0];
    is_ready = next_state == `DUMMY_CACHE_STANDBY;
  end

  integer i;
  always @(posedge clk) begin
    if (reset) begin
      state <= `DUMMY_CACHE_STANDBY;

      idx_0_lru_table <= 4'b1111;
      idx_1_lru_table <= 4'b1111;
      idx_2_lru_table <= 4'b1111;
      idx_3_lru_table <= 4'b1111;

      for (i = 0; i <= 3; i = i + 1) begin
        /* verilator lint_off BLKSEQ */
          set_0_tag_table[i] = 26'b0;  // Empty TAG
          set_0_data_table[i] = 128'b0;
          set_0_valid_table[i] = 1'b0;
          set_0_dirty_table[i] = 1'b0;

          set_1_tag_table[i] = 26'b0;  // Empty TAG
          set_1_data_table[i] = 128'b0;
          set_1_valid_table[i] = 1'b0;
          set_1_dirty_table[i] = 1'b0;

          set_2_tag_table[i] = 26'b0;  // Empty TAG
          set_2_data_table[i] = 128'b0;
          set_2_valid_table[i] = 1'b0;
          set_2_dirty_table[i] = 1'b0;

          set_3_tag_table[i] = 26'b0;  // Empty TAG
          set_3_data_table[i] = 128'b0;
          set_3_valid_table[i] = 1'b0;
          set_3_dirty_table[i] = 1'b0;
        /* verilator lint_on BLKSEQ */
      end
    end else begin
      state <= next_state;
      memory_block <= next_memory_block;
    end
  end

  always @(posedge clk) begin
    if (state == `DUMMY_CACHE_READ) begin
      //$display("%x %x %x %x %x | %x %x %x %x | %x ", tag_of_addr, set_0_tag_table[idx_of_addr], set_1_tag_table[idx_of_addr], set_2_tag_table[idx_of_addr], set_3_tag_table[idx_of_addr], set_0_data_table[idx_of_addr], set_1_data_table[idx_of_addr], set_2_data_table[idx_of_addr], set_3_data_table[idx_of_addr], idx_of_addr);
    end else if (state == `DUMMY_CACHE_WRITE_READ) begin
      // WRITE-HIT
      if (set_0_tag_table[idx_of_addr] == tag_of_addr) begin
      end else if (set_1_tag_table[idx_of_addr] == tag_of_addr) begin
      end else if (set_2_tag_table[idx_of_addr] == tag_of_addr) begin
      end else if (set_3_tag_table[idx_of_addr] == tag_of_addr) begin
      end else begin  //WRITE-MISS -> Check Valid Bit
        if (set_0_valid_table[idx_of_addr] == 1'b0) begin
        end else if (set_1_valid_table[idx_of_addr] == 1'b0) begin
        end else if (set_2_valid_table[idx_of_addr] == 1'b0) begin
        end else if (set_3_valid_table[idx_of_addr] == 1'b0) begin
        end else begin  // WRITE-MISS -> Check Valid Bit -> Check (Pseudo-LRU) ... Reference Corresponding LRU array.
          case (idx_of_addr)
            2'b00: begin
              if (idx_0_lru_table[2'b00] == 1'b0) begin
              end else if (idx_0_lru_table[2'b01] == 1'b0) begin
              end else if (idx_0_lru_table[2'b10] == 1'b0) begin
              end else if (idx_0_lru_table[2'b11] == 1'b0) begin
              end
            end
            2'b01: begin
              if (idx_1_lru_table[2'b00] == 1'b0) begin
              end else if (idx_1_lru_table[2'b01] == 1'b0) begin
              end else if (idx_1_lru_table[2'b10] == 1'b0) begin
              end else if (idx_1_lru_table[2'b11] == 1'b0) begin
              end
            end
            2'b10: begin
              if (idx_2_lru_table[2'b00] == 1'b0) begin
              end else if (idx_2_lru_table[2'b01] == 1'b0) begin
              end else if (idx_2_lru_table[2'b10] == 1'b0) begin
              end else if (idx_2_lru_table[2'b11] == 1'b0) begin
              end
            end
            2'b11: begin
              if (idx_3_lru_table[2'b00] == 1'b0) begin
              end else if (idx_3_lru_table[2'b01] == 1'b0) begin
              end else if (idx_3_lru_table[2'b10] == 1'b0) begin
              end else if (idx_3_lru_table[2'b11] == 1'b0) begin
              end
            end
          endcase
        end
      end
    end
  end
endmodule
