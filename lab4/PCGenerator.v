module PCGenerator (
    input is_branch,
    input is_jalr,
    input [31:0] current_pc,
    input [31:0] rs1_data,
    input [31:0] imm,

    output reg [31:0] next_pc
);
  always @(*) begin
    if (is_jalr) next_pc = rs1_data + imm;
    else if (is_branch) next_pc = current_pc + imm;
    else next_pc = current_pc + 4;
  end
endmodule
