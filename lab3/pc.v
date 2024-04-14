module pc (
    input reset,
    input clk,
    input [31:0] next_pc,
    input pc_write,
    input pc_commit,

    output reg [31:0] current_pc,
    output reg [31:0] next_temp_pc
);
  always @(posedge clk) begin
    if (reset) begin
      current_pc   <= 32'b0;
      next_temp_pc <= 32'b0;
    end else if (pc_write) begin
      next_temp_pc <= next_pc;
      if (pc_commit) current_pc <= next_pc;
    end else if (pc_commit) current_pc <= next_temp_pc;
  end
endmodule
