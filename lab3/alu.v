`include "alu_def.v"

module alu (
    input [ 3:0] alu_op,
    input [31:0] alu_in_1,
    input [31:0] alu_in_2,

    output reg [31:0] alu_result
);

  always @(*) begin
    case (alu_op)
      `ALU_ADD:  alu_result = alu_in_1 + alu_in_2;
      `ALU_SUB:  alu_result = alu_in_1 - alu_in_2;
      `ALU_SLL:  alu_result = alu_in_1 << alu_in_2;
      `ALU_SLT:  alu_result = {31'b0, $signed(alu_in_1) < $signed(alu_in_2)};
      `ALU_SLTU: alu_result = {31'b0, alu_in_1 < alu_in_2};
      `ALU_XOR:  alu_result = alu_in_1 ^ alu_in_2;
      `ALU_SRL:  alu_result = alu_in_1 >> alu_in_2;
      `ALU_SRA:  alu_result = $signed(alu_in_1) >>> alu_in_2;
      `ALU_OR:   alu_result = alu_in_1 | alu_in_2;
      `ALU_AND:  alu_result = alu_in_1 & alu_in_2;
      `ALU_EQ:   alu_result = {31'b0, alu_in_1 == alu_in_2};
      `ALU_NE:   alu_result = {31'b0, alu_in_1 != alu_in_2};
      `ALU_GE:   alu_result = {31'b0, $signed(alu_in_1) >= $signed(alu_in_2)};
      `ALU_GEU:  alu_result = {31'b0, alu_in_1 >= alu_in_2};
      default:   alu_result = 32'hffffffff;
    endcase
  end
endmodule
