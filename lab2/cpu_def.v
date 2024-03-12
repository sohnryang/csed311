// Control unit line definition
`define CONTROL_UNIT_LINES_COUNT    10

`define CONTROL_JALR                4'b0000
`define CONTROL_JAL                 4'b0001
`define CONTROL_BRANCH              4'b0010
`define CONTROL_MEM_READ            4'b0011
`define CONTROL_MEM_TO_REG          4'b0100
`define CONTROL_MEM_WRITE           4'b0101
`define CONTROL_ALU_SRC             4'b0110
`define CONTROL_REG_WRITE           4'b0111
`define CONTROL_PC_TO_REG           4'b1000
`define CONTROL_IS_ECALL            4'b1001
