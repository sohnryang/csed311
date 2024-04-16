module IFIDRegister (
    input clk,
    input reset,

    input write_enable,
    input [31:0] inst_in,

    output reg [31:0] inst_out
);
  always @(posedge clk) begin
    if (reset) inst_out <= 32'b0;
    else if (inst_reg_write) inst_out <= inst_in;
  end
endmodule
