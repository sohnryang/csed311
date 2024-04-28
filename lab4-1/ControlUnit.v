`include "opcodes.v"

module ControlUnit (
    input [6:0] opcode,

    output reg wb_enable,
    output reg mem_enable,
    output reg mem_write,
    output reg op2_imm,
    output reg is_ecall
);
  always @(*) begin
    case (opcode)
      `ARITHMETIC: begin
        wb_enable = 1;
        mem_enable = 0;
        mem_write = 0;
        op2_imm = 0;
        is_ecall = 0;
      end

      `ARITHMETIC_IMM: begin
        wb_enable = 1;
        mem_enable = 0;
        mem_write = 0;
        op2_imm = 1;
        is_ecall = 0;
      end

      `LOAD: begin
        wb_enable = 1;
        mem_enable = 1;
        mem_write = 0;
        op2_imm = 1;
        is_ecall = 0;
      end

      `STORE: begin
        wb_enable = 0;
        mem_enable = 1;
        mem_write = 1;
        op2_imm = 1;
        is_ecall = 0;
      end

      `ECALL: begin
        wb_enable = 0;
        mem_enable = 0;
        mem_write = 0;
        op2_imm = 0;
        is_ecall = 0;
      end

      default: begin
        wb_enable = 0;
        mem_enable = 0;
        mem_write = 0;
        op2_imm = 0;
        is_ecall = 0;
      end
    endcase
  end
endmodule
