module CacheSet (
    input                     clk,
    input                     rst,

    input   [31                :0]  addr,

    output                          hit,
    output  [`SIZE_CACHE_BLK   :0]  data,
)

  reg [`SIZE_CACHE_TAG     :0]  tag_table    [0 :`CACHE_WAY_COUNT - 1];
  reg                           valid_table  [0 :`CACHE_WAY_COUNT - 1];
  reg                           dirty_table  [0 :`CACHE_WAY_COUNT - 1];
  reg [`SIZE_CACHE_BLK     :0]  data_table   [0 :`CACHE_WAY_COUNT - 1];

  always @(*) begin
    if (rst) begin
        /* verilator BLK_SEQ off */
        integer i;
        for (i = 0; i < `CACHE_WAY_COUNT; i = i + 1) begin
          tag_table[i] = `SIZE_CACHE_TAG'b0;  // Empty TAG
          valid_table[i] = 1'b0;              // Invalid
          dirty_table[i] = 1'b0;              // Clean
          data_table[i] = `SIZE_CACHE_BLK'b0; // Fill w/ 0
        end
        /* verilator BLK_SEQ on */
    end

    // ---------- Cache data READ ----------
    if (tag_table[idx] == tag && valid == 1'b1) begin
        assign hit = 1'b1;
        assign data = data_table[idx];
    end else begin
        assign hit = 1'b0;
        assign data = 32'b0;
    end
  end

  always @(posedge clk) begin
    if (update == 1'b1) begin             // Update value
        data_table[update_idx] = update_value;
        valid_table[update_idx] = 1'b0;
    end else if (validate == 1'b1) begin  // Explicitly Validate - might change
        valid_table[update_idx] = 1'b1;
    end
  end
endmodule
