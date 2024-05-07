module PCGenerator (
    input is_branch,
    input is_rd_to_pc,
    input [31:0] current_pc,
    input [31:0] imm,
    input [31:0] alu_result,

    output reg [31:0] next_pc
);
  always @(*) begin
    if (is_rd_to_pc) next_pc = alu_result;
    else if (is_branch && alu_result[0]) next_pc = current_pc + imm;
    else next_pc = current_pc + 4;
  end
endmodule
