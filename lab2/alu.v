`include "alu_def.v"

module alu (
    input [ 3:0] alu_op,
    input [31:0] alu_in_1,
    input [31:0] alu_in_2,

    output [31:0] alu_result
);

  always begin
    case (alu_op)
      `ALU_ADD: begin
        assign alu_result = alu_in_1 + alu_in_2;
      end
      `ALU_SUB: begin
        assign alu_result = alu_in_1 - alu_in_2;
      end
      `ALU_SLL: begin
        assign alu_result = alu_in_1 << alu_in_2;
      end
      `ALU_SLT: begin
        assign alu_result = {31'b0, $signed(alu_in_1) < $signed(alu_in_2)};
      end
      `ALU_SLTU: begin
        assign alu_result = {31'b0, alu_in_1 < alu_in_2};
      end
      `ALU_XOR: begin
        assign alu_result = alu_in_1 ^ alu_in_2;
      end
      `ALU_SRL: begin
        assign alu_result = alu_in_1 >> alu_in_2;
      end
      `ALU_SRA: begin
        assign alu_result = $signed(alu_in_1) >>> alu_in_2;
      end
      `ALU_OR: begin
        assign alu_result = alu_in_1 | alu_in_2;
      end
      `ALU_AND: begin
        assign alu_result = alu_in_1 & alu_in_2;
      end
      `ALU_EQ: begin
        assign alu_result = {31'b0, alu_in_1 == alu_in_2};
      end
      `ALU_NE: begin
        assign alu_result = {31'b0, alu_in_1 != alu_in_2};
      end
    endcase
  end
endmodule
