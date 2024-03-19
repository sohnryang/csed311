`include "alu_def.v"

module alu_control_unit (
    input [16:0] part_of_inst,
    output [3:0] alu_op
);
    wire [6:0] func7 = part_of_inst[16:10];
    wire [2:0] func3 = part_of_inst[9:7];
    wire [6:0] opcode = part_of_inst[6:0];

    
endmodule

module alu (
    input [3:0] alu_op,
    input [31:0] alu_in_1,
    input [31:0] alu_in_2,
    output [31:0] alu_result,
    output alu_bcond
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
            end
            `ALU_SLT: begin
            end
            `ALU_SLTU: begin
            end
            `ALU_XOR: begin
                assign alu_result = alu_in_1 ^ alu_in_2;
            end
            `ALU_SRL: begin
            end
            `ALU_SRA: begin
            end
            `ALU_OR: begin
                assign alu_result = alu_in_1 | alu_in_2;
            end
            `ALU_AND: begin
                assign alu_result = alu_in_1 & alu_in_2;
            end
            `ALU_EQ: begin
                assign alu_bcond = alu_in_1 == alu_in_2;
            end
            `ALU_NE: begin
                assign alu_bcond = alu_in_1 != alu_in_2;
            end
        endcase
    end
endmodule