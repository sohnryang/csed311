module pc (
    input reset,
    input clk,
    input [31:0] next_pc,
    input pc_write,
    input pc_commit,

    output reg [31:0] current_pc
);
  reg [31:0] next_pc_temp;

  always @(posedge clk) begin
    if (reset) begin
      current_pc   <= 32'b0;
      next_pc_temp <= 32'b0;
    end else if (pc_write) begin
      next_pc_temp <= next_pc;
      if (pc_commit) current_pc <= next_pc;
    end else if (pc_commit) current_pc <= next_pc_temp;
  end
endmodule
