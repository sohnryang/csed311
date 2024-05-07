module IFIDRegister (
    input clk,
    input reset,

    input write_enable,

    input [31:0] inst_in,
    input [31:0] pc_in,

    output reg [31:0] inst_out,
    output reg [31:0] pc
);
  always @(posedge clk) begin
    if (reset) begin
      inst_out <= 32'b0;
      pc <= 32'b0;
    end else if (write_enable) begin
      inst_out <= inst_in;
      pc <= pc_in;
    end
  end
endmodule
