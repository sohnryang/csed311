`include "vending_machine_def.v"

module item_selector (
    item_price_table,
    selection_input,
    current_total,

    buy_price,
    buy_item_output
);
  input [31:0] item_price_table[`kNumItems-1:0];
  input [`kNumItems-1:0] selection_input;
  input [31:0] current_total;

  output reg [31:0] buy_price;
  output reg [`kNumItems-1:0] buy_item_output;

  integer i;
  always @(*) begin
    buy_price = 32'b0;
    buy_item_output = `kNumItems'b0;
    for (i = 0; i < `kNumItems; i = i + 1)
    if (selection_input[i] && current_total - buy_price >= item_price_table[i]) begin
      buy_price = buy_price + item_price_table[i];
      buy_item_output[i] = 1;
    end
  end
endmodule
