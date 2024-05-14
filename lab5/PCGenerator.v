module PCGenerator (
    input is_branch,
    input op1_pc,
    input is_jalr,
    input [31:0] current_pc,
    input [31:0] rs1_data,
    input [31:0] imm,
    input [31:0] alu_result,

    output reg [31:0] next_pc
);
  always @(*) begin
    if (is_jalr) next_pc = rs1_data + imm;
    else if (op1_pc || (is_branch && alu_result[0])) next_pc = current_pc + imm;
    else next_pc = current_pc + 4;
  end
endmodule
