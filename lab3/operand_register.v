module operand_register (
    input clk,
    input reset,

    input write,
    input [31:0] data_in1,
    input [31:0] data_in2,

    output reg [31:0] data_out1,
    output reg [31:0] data_out2
);
  always @(posedge clk) begin
    if (reset) begin
      data_out1 <= 32'b0;
      data_out2 <= 32'b0;
    end else if (write) begin
      data_out1 <= data_in1;
      data_out2 <= data_in2;
    end
  end
endmodule
