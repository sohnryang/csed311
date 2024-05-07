`include "opcodes.v"

module ControlUnit (
    input [6:0] opcode,

    output reg wb_enable,
    output reg mem_enable,
    output reg mem_write,
    output reg op1_pc,
    output reg op2_imm,
    output reg is_ecall,
    output reg rs2_used,
    output reg ex_forwardable,
    output reg is_branch,
    output reg is_rd_to_pc
);
  always @(*) begin
    case (opcode)
      `ARITHMETIC: begin
        wb_enable = 1;
        mem_enable = 0;
        mem_write = 0;
        op1_pc = 0;
        op2_imm = 0;
        is_ecall = 0;
        rs2_used = 1;
        ex_forwardable = 1;
        is_branch = 0;
        is_rd_to_pc = 0;
      end

      `ARITHMETIC_IMM: begin
        wb_enable = 1;
        mem_enable = 0;
        mem_write = 0;
        op1_pc = 0;
        op2_imm = 1;
        is_ecall = 0;
        rs2_used = 0;
        ex_forwardable = 1;
        is_branch = 0;
        is_rd_to_pc = 0;
      end

      `LOAD: begin
        wb_enable = 1;
        mem_enable = 1;
        mem_write = 0;
        op1_pc = 0;
        op2_imm = 1;
        is_ecall = 0;
        rs2_used = 0;
        ex_forwardable = 0;
        is_branch = 0;
        is_rd_to_pc = 0;
      end

      `JALR: begin
        wb_enable = 1;
        mem_enable = 0;
        mem_write = 0;
        op1_pc = 0;
        op2_imm = 1;
        is_ecall = 0;
        rs2_used = 0;
        ex_forwardable = 1;
        is_branch = 1;
        is_rd_to_pc = 1;
      end

      `STORE: begin
        wb_enable = 0;
        mem_enable = 1;
        mem_write = 1;
        op1_pc = 0;
        op2_imm = 1;
        is_ecall = 0;
        rs2_used = 1;
        ex_forwardable = 0;
        is_branch = 0;
        is_rd_to_pc = 0;
      end

      `BRANCH: begin
        wb_enable = 0;
        mem_enable = 0;
        mem_write = 0;
        op1_pc = 0;
        op2_imm = 0;
        is_ecall = 0;
        rs2_used = 1;
        ex_forwardable = 0;
        is_branch = 1;
        is_rd_to_pc = 0;
      end

      `JAL: begin
        wb_enable = 1;
        mem_enable = 0;
        mem_write = 0;
        op1_pc = 1;
        op2_imm = 1;
        is_ecall = 0;
        rs2_used = 0;
        ex_forwardable = 1;
        is_branch = 1;
        is_rd_to_pc = 1;
      end

      `ECALL: begin
        wb_enable = 0;
        mem_enable = 0;
        mem_write = 0;
        op1_pc = 0;
        op2_imm = 0;
        is_ecall = 1;
        rs2_used = 0;
        ex_forwardable = 0;
        is_branch = 0;
        is_rd_to_pc = 0;
      end

      default: begin
        wb_enable = 0;
        mem_enable = 0;
        mem_write = 0;
        op1_pc = 0;
        op2_imm = 0;
        is_ecall = 0;
        rs2_used = 0;
        ex_forwardable = 0;
        is_branch = 0;
        is_rd_to_pc = 0;
      end
    endcase
  end
endmodule
