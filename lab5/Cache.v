`include "CLOG2.v"
`include "cache_def.v"

module Cache #(
    parameter LINE_SIZE = `CACHE_LINE_SIZE
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

      .is_input_valid(data_mem_is_input_valid),
      .addr(data_mem_addr >> (`CLOG2(LINE_SIZE))),  // NOTE: address must be shifted by CLOG2(LINE_SIZE)
      .mem_read(data_mem_read),
      .mem_write(data_mem_write),
      .din(data_mem_din),

      // is output from the data memory valid?
      .is_output_valid(data_mem_is_output_valid),
      .dout(data_mem_dout),
      // is data memory ready to accept request?
      .mem_ready(data_mem_ready)
  );

  reg [`CACHE_TAG_BITS - 1:0] tag_of_addr;
  reg [`CACHE_IDX_BITS - 1:0] idx_of_addr;
  reg [31:0] data_mem_addr;

  reg [`CACHE_BLO_BITS - 1:0] block_offset_of_addr;
  reg [1:0] state, next_state;
  reg [`CACHE_WAY_BITS - 1:0] stored_set;
  
  reg [2:0] cache_control;

  // ---------- Cache Definitions ----------
  /*
      3         2         1         0
    [10987654321098765432109876543210]
          TAG 26 bit           IIBBGG
  */
  reg [`CACHE_TAG_BITS - 1: 0]      tag_table [0: `CACHE_SET_COUNT - 1][0: `CACHE_WAY_COUNT - 1];
  reg [LINE_SIZE * 8 - 1: 0]       data_table [0: `CACHE_SET_COUNT - 1][0: `CACHE_WAY_COUNT - 1];
  reg                             valid_table [0: `CACHE_SET_COUNT - 1][0: `CACHE_WAY_COUNT - 1];
  reg                             dirty_table [0: `CACHE_SET_COUNT - 1][0: `CACHE_WAY_COUNT - 1];
  reg [`CACHE_SET_COUNT - 1: 0]     lru_table [0: `CACHE_SET_COUNT - 1];

  reg [`CACHE_WAY_BITS - 1: 0] victim;

  assign is_ready = (next_state == `STATE_CACHE_STANDBY);
  assign is_output_valid = (state == `STATE_CACHE_READ);

  assign tag_of_addr = addr[`CACHE_TAG_FIELD];
  assign idx_of_addr = addr[`CACHE_IDX_FIELD];
  assign block_offset_of_addr = addr[`CACHE_BLO_FIELD];    

  assign is_hit = (
    ((tag_table[idx_of_addr][0] == tag_of_addr) && (valid_table[idx_of_addr][0] == 1'b1)) ||    
    ((tag_table[idx_of_addr][1] == tag_of_addr) && (valid_table[idx_of_addr][1] == 1'b1)) ||    // |Cache set| = 3
    ((tag_table[idx_of_addr][2] == tag_of_addr) && (valid_table[idx_of_addr][2] == 1'b1)) ||
    ((tag_table[idx_of_addr][3] == tag_of_addr) && (valid_table[idx_of_addr][3] == 1'b1)) //||    // |Cache set| = 2
    // ((tag_table[idx_of_addr][4] == tag_of_addr) && (valid_table[idx_of_addr][4] == 1'b1)) ||
    // ((tag_table[idx_of_addr][5] == tag_of_addr) && (valid_table[idx_of_addr][5] == 1'b1)) ||
    // ((tag_table[idx_of_addr][6] == tag_of_addr) && (valid_table[idx_of_addr][6] == 1'b1)) ||
    // ((tag_table[idx_of_addr][7] == tag_of_addr) && (valid_table[idx_of_addr][7] == 1'b1))       // |Cache set| = 1
  );

  always @(*) begin
    integer b;
    stored_set = 0;
    for (b = 0; b <= `CACHE_SET_COUNT - 1; b = b + 1) begin
      if ((tag_table[idx_of_addr][b] == tag_of_addr) && (valid_table[idx_of_addr][b] == 1'b1)) begin
        stored_set = `CACHE_WAY_BITS'(b);
      end
    end
  end

  always @(*) begin
    case (state)
      `STATE_CACHE_STANDBY: begin
        if (is_input_valid) begin
          next_state = `STATE_CACHE_READ;
        end else begin
          next_state = `STATE_CACHE_STANDBY;
        end
      end
      `STATE_CACHE_READ: begin
        if (is_hit) begin
          next_state = `STATE_CACHE_STANDBY;
        end else begin
          if (dirty_table[idx_of_addr][victim]) begin
            next_state = `STATE_CACHE_WRITE_WRITE;
          end else begin
            next_state = `STATE_CACHE_WRITE_READ;
          end
        end
      end
      `STATE_CACHE_WRITE_READ: begin
        if (data_mem_ready) begin
          next_state = `STATE_CACHE_READ;
        end else begin
          next_state = `STATE_CACHE_WRITE_READ;
        end
      end
      `STATE_CACHE_WRITE_WRITE: begin
        if (data_mem_ready) begin
          next_state = `STATE_CACHE_WRITE_READ;
        end else begin
          next_state = `STATE_CACHE_WRITE_WRITE;
        end
      end
    endcase
  end

  always @(*) begin
    data_mem_is_input_valid = 0;
    cache_control = 0;
    dout = data_table[idx_of_addr][stored_set][block_offset_of_addr * 32 + 31 -: 32];

    case (state)
      `STATE_CACHE_STANDBY: begin
        cache_control = 0;
        data_mem_is_input_valid = 0;
        data_mem_addr = addr;
        data_mem_read = 0;
        data_mem_write = 0;
        data_mem_din = 0;
      end
      `STATE_CACHE_READ: begin
        if (is_hit) begin   // Hit
          if (mem_rw) begin
            cache_control |= `ACTION_WRITE_CACHE;
          end
          data_mem_is_input_valid = 0;
          data_mem_addr = addr;
          data_mem_read = 0;
          data_mem_write = 0;
          data_mem_din = data_table[idx_of_addr][stored_set];
        end else begin    // Miss
          if (next_state == `STATE_CACHE_WRITE_WRITE) begin   // Miss Write -> Write current cache back to memory
            data_mem_is_input_valid = 1;
            data_mem_addr = {tag_table[idx_of_addr][victim], idx_of_addr, 4'b0};
            data_mem_read = 0;
            data_mem_write = 1;
          end else if (next_state == `STATE_CACHE_WRITE_READ) begin   // Miss Read -> Fetch from memory
            data_mem_is_input_valid = 1;
            data_mem_addr = addr;
            data_mem_read = 1;
            data_mem_write = 0;
          end else begin
            data_mem_is_input_valid = 0;
            data_mem_addr = addr;
            data_mem_read = 0;
            data_mem_write = 0;
          end
          data_mem_din = data_table[idx_of_addr][victim];
        end
      end
      `STATE_CACHE_WRITE_READ: begin
        if (data_mem_ready) begin
          cache_control |= `ACTION_ALLOC_CACHE;
        end
        data_mem_is_input_valid = 0;
        data_mem_addr = addr;
        data_mem_read = 0;
        data_mem_write = 0;
        data_mem_din = 0;
      end
      `STATE_CACHE_WRITE_WRITE: begin
        if (next_state == `STATE_CACHE_WRITE_READ) begin
          data_mem_is_input_valid = 1;
          data_mem_read = 1;
          data_mem_write = 0;
        end else begin
          data_mem_is_input_valid = 0;
          data_mem_read = 0;
          data_mem_write = 0;
        end
        if (data_mem_ready) begin
          cache_control |= `ACTION_EMPTY_CACHE;
        end
        data_mem_din = data_table[idx_of_addr][victim];
        data_mem_addr = addr;
      end
    endcase
  end

  integer i;
  integer j;
  integer b;
  always @(posedge clk) begin
    if (reset) begin
      state <= `STATE_CACHE_STANDBY;
      /* verilator lint_off BLKSEQ */
      for (i = 0; i < `CACHE_SET_COUNT; i = i + 1) begin
        for (j = 0; j < `CACHE_WAY_COUNT; j = j + 1) begin
          tag_table[i][j] = {(`CACHE_TAG_BITS) {1'b0}};
          data_table[i][j] = {(LINE_SIZE * 8) {1'b0}};
          valid_table[i][j] = 1'b0;
          dirty_table[i][j] = 1'b0;
        end
        lru_table[i] = {(`CACHE_SET_COUNT) {1'b0}};
      end
      /* verilator lint_on BLKSEQ */
    end else begin
      state <= next_state;

      // ---------- Bit-PLRU (Pseudo LRU) ----------
      if (is_hit) begin
        if ((tag_table[idx_of_addr][stored_set] == tag_of_addr) && (valid_table[idx_of_addr][stored_set] == 1'b1)) begin // Cache Hit
          if ((lru_table[idx_of_addr] | (1 << stored_set)) == {`CACHE_SET_COUNT {1'b1}}) begin  // Filled with 1?
            lru_table[idx_of_addr] <= (1 << stored_set); // Set everything except hit index as 0
          end else
            lru_table[idx_of_addr] <= (lru_table[idx_of_addr] | (1 << stored_set)); // Assign hit on the bit
        end
      end else begin
        for (b = 0; b <= `CACHE_SET_COUNT - 1; b = b + 1) begin
          if ((lru_table[idx_of_addr] & (1 << b)) == {`CACHE_SET_COUNT {1'b0}}) begin
            victim <= `CACHE_WAY_BITS'(b);
          end
        end
      end

      if ((cache_control & `ACTION_WRITE_CACHE) != 0) begin
        data_table[idx_of_addr][stored_set][block_offset_of_addr * 32 + 31 -: 32] <= din;
        dirty_table[idx_of_addr][stored_set] <= 1'b1;
      end

      if ((cache_control & `ACTION_ALLOC_CACHE) != 0) begin
        tag_table[idx_of_addr][victim] <= tag_of_addr;
        valid_table[idx_of_addr][victim] <= 1'b1;
        data_table[idx_of_addr][victim] <= data_mem_dout;
      end

      if ((cache_control & `ACTION_EMPTY_CACHE) != 0) begin
        tag_table[idx_of_addr][victim] <= 0;
        valid_table[idx_of_addr][victim] <= 0;
        dirty_table[idx_of_addr][victim] <= 0;
        data_table[idx_of_addr][victim] <= 0; 
      end
    end
  end
endmodule
