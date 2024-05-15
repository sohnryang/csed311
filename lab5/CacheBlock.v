module CacheBlock #(
    parameter BLK_SIZE = 0;
    parameter TAG_SIZE = 0;
    parameter DATA_SIZE = 0;
    parameter LINE_SIZE = 0;
    parameter IDX_SIZE = 0;
) (
    input                     clk,
    input                     rst,

    input   [31         :0]   addr,
    input   [TAG_SIZE   :0]   tag,
    input   [IDX_SIZE   :0]   idx,

    output                    hit,
    output  [BLK_SIZE   :0]   data,

    /* For cache update */
    input                     update,
    input   [31         :0]   update_addr,
    input   [BLK_SIZE   :0]   update_value;

    input                     validate,
    input   [31         :0]   valid_addr
)

  reg [TAG_SIZE     :0] tag_table    [0 :BLK_SIZE - 1];
  reg                   valid_table  [0 :BLK_SIZE - 1];
  reg [LINE_SIZE    :0] data_table   [0 :BLK_SIZE - 1];

  always @(*) begin
    if (rst) begin
        /* verilator BLK_SEQ off */
        // Fill 0 to cache blocks
        /* verilator BLK_SEQ on */
    end

    /* Return cache data */
    if (tag_table[idx] == tag && valid == 1'b1) begin
        assign hit = 1'b1;
        assign data = data_table[idx];
    end else begin
        assign hit = 1'b0;
        assign data = 32'b0;
    end
  end

  always @(posedge clk) begin
    if (update == 1'b1) begin
        data_table[/* INDEX from update_addr */] = update_value;
        valid_table[/* INDEX from update_addr */] = 1'b0;   // Invalidate
    end else if (validate == 1'b1) begin
        valid_table[/* INDEX from validate_addr */] = 1'b1;   // Invalidate
    end
  end
endmodule