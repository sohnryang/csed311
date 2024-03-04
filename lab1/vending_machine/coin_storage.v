`include "vending_machine_def.v"

module coin_storage (
    clk,
    reset_n,

    coin_value_table,
    coin_input,
    buy_price_input,
    trigger_return,

    coin_value,
    return_coins
);
  input clk;
  input reset_n;

  input [31:0] coin_value_table[`kNumCoins-1:0];
  input [`kNumCoins-1:0] coin_input;
  input [31:0] buy_price_input;
  input trigger_return;

  output reg [31:0] coin_value;
  output reg [`kNumCoins-1:0] return_coins;

  wire [31:0] input_value;
  coin_value_calculator coin_value_calculator_mod0 (
      .coin_value_table(coin_value_table),
      .coin_input(coin_input),
      .coin_value(input_value)
  );

  wire [`kNumCoins-1:0] return_coins_mod_output;
  return_value_calculator return_value_calculator_mod (
      .coin_value_table(coin_value_table),
      .coin_value(coin_value),
      .return_coins(return_coins_mod_output)
  );

  wire [31:0] return_value_mod_output;
  coin_value_calculator coin_value_calculator_mod1 (
      .coin_value_table(coin_value_table),
      .coin_input(return_coins_mod_output),
      .coin_value(return_value_mod_output)
  );

  reg [31:0] coin_value_next;
  reg [`kNumCoins-1:0] return_coins_next;
  always @(*) begin
    if (trigger_return) begin
      coin_value_next   = coin_value - return_value_mod_output;
      return_coins_next = return_coins_mod_output;
    end else begin
      return_coins_next = `kNumCoins'b0;
      if (buy_price_input != 32'b0) coin_value_next = coin_value - buy_price_input;
      else coin_value_next = coin_value + input_value;
    end
  end

  always @(posedge clk) begin
    if (!reset_n) begin
      coin_value   <= 32'b0;
      return_coins <= `kNumCoins'b0;
    end else begin
      coin_value   <= coin_value_next;
      return_coins <= return_coins_next;
    end
  end
endmodule
