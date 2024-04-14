module pc (
    input reset,
    input clk,
    input [31:0] next_pc,
    input pc_write,

    output reg [31:0] current_pc
);
  always @(posedge clk) begin
    if (reset) current_pc <= 32'b0;
    else if (pc_write) current_pc <= next_pc;
  end
endmodule
