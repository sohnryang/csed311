module instruction_register (
    input clk,
    input reset,

    input ir_write,
    input [31:0] data_in,

    output reg [31:0] inst
);
  always @(posedge clk) begin
    if (reset) inst <= 32'b0;
    else if (ir_write) inst <= data_in;
  end
endmodule
