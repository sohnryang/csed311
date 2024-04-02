module alu_register (
    input clk,
    input reset,

    input write,
    input [31:0] data_in,

    output reg [31:0] data_out
);
  always @(posedge clk) begin
    if (reset) data_out <= 32'b0;
    else if (write) data_out <= data_in;
  end
endmodule
