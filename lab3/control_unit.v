`include "alu_def.v"
`include "opcodes.v"
`include "control_unit_def.v"

module control_unit (
    input clk,
    input reset,

    input [6:0] opcode,

    output reg inst_reg_write,
    output reg data_access,
    output reg mem_read,
    output reg mem_write,
    output reg op_reg_write,
    output reg op1_regfile,
    output reg [1:0] op2_sel,
    output reg is_ecall,
    output reg alu_reg_write,
    output reg alu_op_from_inst,
    output reg [3:0] alu_op,
    output reg mem_reg_write,
    output reg regfile_write,
    output reg [1:0] wb_sel,
    output reg pc_write_cond,
    output reg pc_write,
    output reg pc_commit,
    output reg pc_from_alu_reg
);
  reg [2:0] state;
  reg [2:0] next_state;

  always @(*) begin
    case (state)
      `CTRL_IF_STAGE: begin
        inst_reg_write = 1;
        data_access = 0;
        mem_read = 1;
        mem_write = 0;
        op_reg_write = 0;
        op1_regfile = 0;
        op2_sel = `CTRL_OP2_FOUR;
        is_ecall = 0;
        alu_reg_write = 0;
        alu_op_from_inst = 0;
        alu_op = `ALU_ADD;
        mem_reg_write = 0;
        regfile_write = 0;
        wb_sel = 2'b0;
        pc_write_cond = 0;
        pc_write = 1;
        pc_commit = 0;
        pc_from_alu_reg = 0;

        next_state = `CTRL_ID_STAGE;
      end

      `CTRL_ID_STAGE: begin
        inst_reg_write = 0;
        data_access = 0;
        mem_read = 0;
        mem_write = 0;
        op_reg_write = 1;
        op1_regfile = 0;
        op2_sel = `CTRL_OP2_IMM;
        is_ecall = opcode == `ECALL;
        alu_reg_write = 1;
        alu_op_from_inst = 0;
        alu_op = `ALU_ADD;
        mem_reg_write = 0;
        pc_write_cond = 0;
        pc_write = 0;
        pc_commit = 0;
        pc_from_alu_reg = 0;

        if (opcode == `JAL || opcode == `JALR) begin
          regfile_write = 1;
          wb_sel = `CTRL_WB_ALU_DIRECT;
        end else begin
          regfile_write = 0;
          wb_sel = 2'b0;
        end

        next_state = `CTRL_EX_STAGE;
      end

      `CTRL_EX_STAGE: begin
        inst_reg_write = 0;
        data_access = 0;
        mem_read = 0;
        mem_write = 0;
        op_reg_write = 0;
        is_ecall = opcode == `ECALL;
        mem_reg_write = 0;
        regfile_write = 0;
        wb_sel = 2'b0;

        case (opcode)
          `ARITHMETIC: begin
            op1_regfile = 1;
            op2_sel = `CTRL_OP2_REG;
            alu_reg_write = 1;
            alu_op_from_inst = 1;
            alu_op = `ALU_ADD;
            pc_write = 0;
            pc_commit = 0;
            pc_write_cond = 0;
            pc_from_alu_reg = 0;
            next_state = `CTRL_WB_STAGE;
          end
          `ARITHMETIC_IMM: begin
            op1_regfile = 1;
            op2_sel = `CTRL_OP2_IMM;
            alu_reg_write = 1;
            alu_op_from_inst = 1;
            alu_op = `ALU_ADD;
            pc_write = 0;
            pc_commit = 0;
            pc_write_cond = 0;
            pc_from_alu_reg = 0;
            next_state = `CTRL_WB_STAGE;
          end
          `LOAD: begin
            op1_regfile = 1;
            op2_sel = `CTRL_OP2_IMM;
            alu_reg_write = 1;
            alu_op_from_inst = 0;
            alu_op = `ALU_ADD;
            pc_write = 0;
            pc_commit = 0;
            pc_write_cond = 0;
            pc_from_alu_reg = 0;
            next_state = `CTRL_MEM_STAGE;
          end
          `JALR: begin
            op1_regfile = 1;
            op2_sel = `CTRL_OP2_IMM;
            alu_reg_write = 0;
            alu_op_from_inst = 0;
            alu_op = `ALU_ADD;
            pc_write = 1;
            pc_commit = 0;
            pc_write_cond = 0;
            pc_from_alu_reg = 0;
            next_state = `CTRL_WB_STAGE;
          end
          `STORE: begin
            op1_regfile = 1;
            op2_sel = `CTRL_OP2_IMM;
            alu_reg_write = 1;
            alu_op_from_inst = 0;
            alu_op = `ALU_ADD;
            pc_write = 0;
            pc_commit = 1;
            pc_write_cond = 0;
            pc_from_alu_reg = 0;
            next_state = `CTRL_MEM_STAGE;
          end
          `BRANCH: begin
            op1_regfile = 1;
            op2_sel = `CTRL_OP2_REG;
            alu_reg_write = 0;
            alu_op_from_inst = 1;
            alu_op = `ALU_ADD;
            pc_write = 0;
            pc_commit = 1;
            pc_write_cond = 1;
            pc_from_alu_reg = 1;
            next_state = `CTRL_IF_STAGE;
          end
          `JAL: begin
            op1_regfile = 0;
            op2_sel = `CTRL_OP2_IMM;
            alu_reg_write = 0;
            alu_op_from_inst = 0;
            alu_op = 4'b0;
            pc_write = 1;
            pc_commit = 0;
            pc_write_cond = 0;
            pc_from_alu_reg = 1;
            next_state = `CTRL_WB_STAGE;
          end
          `ECALL: begin
            op1_regfile = 0;
            op2_sel = 2'b0;
            alu_reg_write = 0;
            alu_op_from_inst = 0;
            alu_op = 4'b0;
            pc_write = 0;
            pc_commit = 1;
            pc_write_cond = 0;
            pc_from_alu_reg = 0;
            next_state = `CTRL_IF_STAGE;
          end
          default: begin
            op1_regfile = 0;
            op2_sel = 2'b0;
            alu_reg_write = 0;
            alu_op_from_inst = 0;
            alu_op = 4'b0;
            pc_write = 0;
            pc_commit = 0;
            pc_write_cond = 0;
            pc_from_alu_reg = 0;
            next_state = `CTRL_ID_STAGE;
          end
        endcase
      end

      `CTRL_MEM_STAGE: begin
        inst_reg_write = 0;
        data_access = 1;
        mem_read = opcode == `LOAD;
        mem_write = opcode == `STORE;
        op_reg_write = 0;
        op1_regfile = 0;
        op2_sel = 2'b0;
        is_ecall = opcode == `ECALL;
        alu_reg_write = 0;
        alu_op_from_inst = 0;
        alu_op = 4'b0;
        mem_reg_write = opcode == `LOAD;
        regfile_write = 0;
        wb_sel = 2'b0;
        pc_write_cond = 0;
        pc_write = 0;
        pc_commit = 0;
        pc_from_alu_reg = 0;

        if (opcode == `STORE) next_state = `CTRL_IF_STAGE;
        else next_state = `CTRL_WB_STAGE;
      end

      `CTRL_WB_STAGE: begin
        inst_reg_write = 0;
        data_access = 0;
        mem_read = 0;
        mem_write = 0;
        op_reg_write = 0;
        op1_regfile = 0;
        op2_sel = 2'b0;
        is_ecall = opcode == `ECALL;
        alu_reg_write = 0;
        alu_op_from_inst = 0;
        alu_op = 4'b0;
        mem_reg_write = 0;
        pc_write_cond = 0;
        pc_write = 0;
        pc_commit = 1;
        pc_from_alu_reg = 0;

        case (opcode)
          `ARITHMETIC: begin
            regfile_write = 1;
            wb_sel = `CTRL_WB_ALU_REG;
          end
          `ARITHMETIC_IMM: begin
            regfile_write = 1;
            wb_sel = `CTRL_WB_ALU_REG;
          end
          `LOAD: begin
            regfile_write = 1;
            wb_sel = `CTRL_WB_MEM;
          end
          default: begin
            regfile_write = 0;
            wb_sel = 2'b0;
          end
        endcase

        next_state = `CTRL_IF_STAGE;
      end

      default: begin
        inst_reg_write = 0;
        data_access = 0;
        mem_read = 0;
        mem_write = 0;
        op_reg_write = 0;
        op1_regfile = 0;
        op2_sel = 2'b0;
        is_ecall = 0;
        alu_reg_write = 0;
        alu_op_from_inst = 0;
        alu_op = 4'b0;
        mem_reg_write = 0;
        regfile_write = 0;
        wb_sel = 2'b0;
        pc_write_cond = 0;
        pc_write = 0;
        pc_from_alu_reg = 0;

        next_state = `CTRL_IF_STAGE;
      end
    endcase
  end

  always @(posedge clk) begin
    if (reset) begin
      state <= `CTRL_IF_STAGE;
    end else begin
      state <= next_state;
    end
  end
endmodule
