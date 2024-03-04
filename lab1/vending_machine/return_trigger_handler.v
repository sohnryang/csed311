`include "vending_machine_def.v"

module return_trigger_handler (
    clk,
    reset_n,

    trigger_return,

    delayed_trigger_return
);
  input clk;
  input reset_n;

  input trigger_return;

  output reg delayed_trigger_return;

  reg prev_trigger_return;
  reg [2:0] remaining_delay_time;
  always @(posedge clk) begin
    if (!reset_n) begin
      prev_trigger_return  <= 0;
      remaining_delay_time <= 3'd`kTriggerWait;
    end else if (trigger_return) begin
      if (remaining_delay_time <= 3'b0) begin
        delayed_trigger_return <= 1;
        prev_trigger_return <= trigger_return;
      end else if (prev_trigger_return) begin
        remaining_delay_time <= remaining_delay_time - 3'b1;
        prev_trigger_return  <= trigger_return;
      end else prev_trigger_return <= trigger_return;
    end else begin
      delayed_trigger_return <= 0;
      prev_trigger_return <= trigger_return;
      remaining_delay_time <= 3'd`kTriggerWait;
    end
  end
endmodule
