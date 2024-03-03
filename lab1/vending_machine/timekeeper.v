`include "vending_machine_def.v"

module timekeeper (
    clk,
    reset_n,

    current_total,
    coin_input,
    selection_input,
    trigger_return,

    timeout
);
  input clk;
  input reset_n;

  input [31:0] current_total;
  input [`kNumCoins-1:0] coin_input;
  input [`kNumItems-1:0] selection_input;
  input trigger_return;

  output reg timeout;

  reg [31:0] remaining_time;
  reg timer_started;
  always @(posedge clk) begin
    if (!reset_n) begin
      remaining_time <= 0;
      timer_started  <= 0;
      timeout <= 0;
    end else if (trigger_return || (timer_started && remaining_time == 32'b0)) begin
      if (current_total != 32'b0) timeout <= 1;
      else begin
        timeout <= 0;
        timer_started  <= 0;
      end
    end else if (coin_input != `kNumCoins'b0 || selection_input != `kNumItems'b0) begin
      remaining_time <= 32'd`kWaitTime;
      timer_started  <= 1;
      timeout <= 0;
    end else if (timer_started) remaining_time <= remaining_time - 1;
  end
endmodule
