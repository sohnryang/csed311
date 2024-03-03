// Title         : vending_machine.v
// Author      : Jae-Eon Jo (Jojaeeon@postech.ac.kr) 
//			     Dongup Kwon (nankdu7@postech.ac.kr) (2015.03.30)
//			     Jaehun Ryu (jaehunryu@postech.ac.kr) (2021.03.07)

`include "vending_machine_def.v"

module vending_machine (
    clk,  // Clock signal
    reset_n,  // Reset signal (active-low)

    i_input_coin,  // coin is inserted.
    i_select_item,  // item is selected.
    i_trigger_return,  // change-return is triggered 

    o_available_item,  // Sign of the item availability
    o_output_item,  // Sign of the item withdrawal
    o_return_coin  // Sign of the coin return
);
  // Ports Declaration
  // Do not modify the module interface
  input clk;
  input reset_n;

  input [`kNumCoins-1:0] i_input_coin;
  input [`kNumItems-1:0] i_select_item;
  input i_trigger_return;

  output [`kNumItems-1:0] o_available_item;
  output [`kNumItems-1:0] o_output_item;
  output [`kNumCoins-1:0] o_return_coin;

  // Do not modify the values.
  wire [31:0] item_price[`kNumItems-1:0];  // Price of each item
  wire [31:0] coin_value[`kNumCoins-1:0];  // Value of each coin
  assign item_price[0] = 400;
  assign item_price[1] = 500;
  assign item_price[2] = 1000;
  assign item_price[3] = 2000;
  assign coin_value[0] = 100;
  assign coin_value[1] = 500;
  assign coin_value[2] = 1000;

  wire [31:0] current_total, buy_price;

  // This module interface, structure, and given a number of modules are not mandatory but recommended.
  // However, Implementations that use modules are mandatory.
  coin_storage coin_storage_mod (
      .clk(clk),
      .reset_n(reset_n),
      .coin_value_table(coin_value),
      .coin_input(i_input_coin),
      .buy_price_input(buy_price),
      .trigger_return(i_trigger_return),
      .coin_value(current_total),
      .return_coins(o_return_coin)
  );

  item_display item_display_mod (
      .item_price_table(item_price),
      .current_total(current_total),
      .item_output(o_available_item)
  );

  item_selector item_selector_mod (
      .item_price_table(item_price),
      .selection_input(i_select_item),
      .current_total(current_total),
      .buy_price(buy_price),
      .buy_item_output(o_output_item)
  );
endmodule
