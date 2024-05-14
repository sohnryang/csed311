module IFIDRegister (
    input clk,
    input reset,

    input write_enable,
    input bubble_in,

    input [31:0] inst_in,
    input [31:0] pc_in,

    output reg valid,
    output reg bubble,

    output reg [31:0] inst_out,
    output reg [31:0] pc
);
  always @(posedge clk) begin
    if (reset) begin
      valid <= 0;
      bubble <= 0;

      inst_out <= 32'b0;
      pc <= 32'b0;
    end else if (write_enable) begin
      valid <= 1;
      bubble <= bubble_in;

      inst_out <= inst_in;
      pc <= pc_in;
    end
  end
endmodule
