module CacheSet (
    input                     clk,
    input                     rst,

    input   [31                :0]  addr,
    input   [`SIZE_CACHE_BLK   :0]  din,
    input                           is_input_valid,
    output                          hit,
    output  [`SIZE_CACHE_BLK   :0]  dout,
    output                          is_output_valid,
)

  reg [`SIZE_CACHE_TAG     :0]  tag_table    [0 :`CACHE_WAY_COUNT - 1];
  reg                           valid_table  [0 :`CACHE_WAY_COUNT - 1];
  reg                           dirty_table  [0 :`CACHE_WAY_COUNT - 1];
  reg [`SIZE_CACHE_BLK     :0]  data_table   [0 :`CACHE_WAY_COUNT - 1];

  reg [1:0] cache_state_current;
  reg [1:0] cache_state_next;

  always @(posedge clk) begin
    if (rst) begin
        /* verilator BLK_SEQ off */
        cache_state_current = `STATUS_CACHE_WAIT;
        cache_state_next = `STATUS_CACHE_WAIT;
        integer i;
        for (i = 0; i < `CACHE_WAY_COUNT; i = i + 1) begin
          tag_table[i] = `SIZE_CACHE_TAG'b0;  // Empty TAG
          valid_table[i] = 1'b0;              // Invalid
          dirty_table[i] = 1'b0;              // Clean
          data_table[i] = `SIZE_CACHE_BLK'b0; // Fill w/ 0
        end
        /* verilator BLK_SEQ on */
    end
    cache_state_current <= cache_state_next;
  end

  always @(*) begin
    // ----------     Cache Hit Check     ----------
    // ---------- Asynchronous Cache Read ----------
    if (tag_table[addr[`ADDR_EXTRACT_CACHE_IDX]] == addr[`ADDR_EXTRACT_CACHE_TAG]) begin
      // (Cache HIT , Cache Data)
      hit <= 1'b1
      dout <= (data_table[addr[`ADDR_EXTRACT_CACHE_IDX]][(addr[`ADDR_EXTRACT_CACHE_BO] * 32): (addr[`ADDR_EXTRACT_CACHE_BO] * 32) + 31]);
    end else begin
      // (Cache Miss, 32'b0)
      hit = 1'b0
      dout = 32'b0;
    end

    case(cache_state_current) begin
      `STATUS_CACHE_WAIT: begin
        if(is_input_valid) begin
          cache_state_next <= `STATUS_CACHE_CHECK;
        end
      end
      `STATUS_CACHE_CHECK: begin
        if (/* Cache Hit */) begin
          if (/* Cache Read */) begin

          end else begin /* Cache Write */
            if (/* Write target is Clean */) begin
            end else /* Write target is Dirty */
          end
        end else begin
          /* Cache Miss */
        end
      end
      `STATUS_CACHE_WRITE: begin
      end
      `STATUS_CACHE_READY: begin
      end
    endcase
  end
endmodule
