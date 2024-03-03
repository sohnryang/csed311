`include "vending_machine_def.v"

module return_value_calculator (
    coin_value_table,
    coin_value,

    return_coins
);
  input [31:0] coin_value_table[`kNumCoins-1:0];
  input [31:0] coin_value;

  output reg [`kNumCoins-1:0] return_coins;

  integer i;
  reg [31:0] current_value;
  always @(*) begin
    current_value = coin_value;
    for (i = 0; i < `kNumCoins; i = i + 1) begin
      if (current_value >= coin_value_table[i]) begin
        return_coins[i] = 1;
      end else
        return_coins[i] = 0;
    end
  end
endmodule
