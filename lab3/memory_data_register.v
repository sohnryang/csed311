module memory_data_register (
    input clk,
    input reset,

    input [31:0] data_in,

    output reg [31:0] stored_data
);
  always @(posedge clk) begin
    if (reset) stored_data <= 32'b0;
    else stored_data <= data_in;
  end
endmodule
