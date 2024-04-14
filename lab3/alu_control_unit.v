`include "alu_def.v"
`include "opcodes.v"

module alu_control_unit (
    input [16:0] part_of_inst,
    input [3:0] alu_op_from_ctrl,
    input enable,

    output reg [3:0] alu_op
);
  wire [6:0] func7 = part_of_inst[16:10];
  wire [2:0] func3 = part_of_inst[9:7];
  wire [6:0] opcode = part_of_inst[6:0];

  always @(*) begin
    if (enable)
      case (opcode)
        `ARITHMETIC: begin
          case (func3)
            `FUNCT3_ADD_SUB: begin
              if (func7 == `FUNCT7_SUB) alu_op = `ALU_SUB;
              else if (func7 == `FUNCT7_OTHERS) alu_op = `ALU_ADD;
              else alu_op = `ALU_ERR;
            end
            `FUNCT3_SLL: alu_op = `ALU_SLL;
            `FUNCT3_SLT: alu_op = `ALU_SLT;
            `FUNCT3_SLTU: alu_op = `ALU_SLTU;
            `FUNCT3_XOR: alu_op = `ALU_XOR;
            `FUNCT3_SRL_SRA: begin
              if (func7 == `FUNCT7_SUB) alu_op = `ALU_SRA;
              else if (func7 == `FUNCT7_OTHERS) alu_op = `ALU_SRL;
              else alu_op = `ALU_ERR;
            end
            `FUNCT3_OR: alu_op = `ALU_OR;
            `FUNCT3_AND: alu_op = `ALU_AND;
            default: alu_op = `ALU_ERR;
          endcase
        end
        `ARITHMETIC_IMM: begin
          case (func3)
            `FUNCT3_ADD_SUB: alu_op = `ALU_ADD;
            `FUNCT3_SLT: alu_op = `ALU_SLT;
            `FUNCT3_SLTU: alu_op = `ALU_SLTU;
            `FUNCT3_XOR: alu_op = `ALU_XOR;
            `FUNCT3_OR: alu_op = `ALU_OR;
            `FUNCT3_AND: alu_op = `ALU_AND;
            `FUNCT3_SLL: alu_op = `ALU_SLL;
            `FUNCT3_SRL_SRA: begin
              if (func7 == `FUNCT7_SUB) alu_op = `ALU_SRA;
              else if (func7 == `FUNCT7_OTHERS) alu_op = `ALU_SRL;
              else alu_op = `ALU_ERR;
            end
            default: alu_op = `ALU_ERR;
          endcase
        end
        `BRANCH: begin
          case (func3)
            `FUNCT3_BEQ: alu_op = `ALU_EQ;
            `FUNCT3_BNE: alu_op = `ALU_NE;
            `FUNCT3_BLT: alu_op = `ALU_SLT;
            `FUNCT3_BGE: alu_op = `ALU_GE;
            `FUNCT3_BLTU: alu_op = `ALU_SLTU;
            `FUNCT3_BGEU: alu_op = `ALU_GEU;
            default: alu_op = `ALU_ERR;
          endcase
        end
        default: alu_op = `ALU_ERR;
      endcase
    else alu_op = alu_op_from_ctrl;
  end
endmodule
