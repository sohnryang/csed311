module immediate_generator (
    input [31:0] inst,

    output [31:0] i_imm,
    output [31:0] s_imm,
    output [31:0] b_imm,
    output [31:0] u_imm,
    output [31:0] j_imm
);
  assign i_imm = {{21{inst[31]}}, inst[30:20]};
  assign s_imm = {{21{inst[31]}}, inst[30:25], inst[11:7]};
  assign b_imm = {{20{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0};
  assign u_imm = {inst[31], inst[30:20], inst[19:12], 12'b0};
  assign j_imm = {{12{inst[31]}}, inst[19:12], inst[20], inst[30:25], inst[24:21], 1'b0};
endmodule
