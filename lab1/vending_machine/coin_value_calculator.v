`include "vending_machine_def.v"

module coin_value_calculator (
    coin_value_table,
    coin_input,
    coin_value
);
  input [31:0] coin_value_table[`kNumCoins-1:0];
  input [`kNumCoins-1:0] coin_input;

  output reg [31:0] coin_value;

  integer i;
  always @(*) begin
    coin_value = 32'b0;
    for (i = 0; i < `kNumCoins; i = i + 1)
      coin_value = coin_value + coin_value_table[i] * coin_input[i];
  end
endmodule
