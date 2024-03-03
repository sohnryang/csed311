`include "vending_machine_def.v"

module item_display (
    item_price_table,
    current_total,

    item_output
);
  input [31:0] item_price_table[`kNumItems-1:0];
  input [31:0] current_total;

  output reg [`kNumItems-1:0] item_output;

  integer i;
  always @(*) begin
    for (i = 0; i < `kNumItems; i = i + 1) item_output[i] = current_total >= item_price_table[i];
  end
endmodule
