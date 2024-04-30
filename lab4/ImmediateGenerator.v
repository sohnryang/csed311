module ImmediateGenerator (
    input [31:0] inst,

    output reg [31:0] imm
);
  wire [6:0] opcode = inst[6:0];
  wire [2:0] func3 = inst[14:12];

  always @(*) begin
    case (opcode)
      `ARITHMETIC_IMM: begin
        if (func3 == `FUNCT3_SLL || func3 == `FUNCT3_SRL) imm = {{27'b0, inst[24:20]}};
        else imm = {{21{inst[31]}}, inst[30:20]};
      end
      `BRANCH: imm = {{20{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0};
      `LOAD: imm = {{21{inst[31]}}, inst[30:20]};
      `JAL: imm = {{12{inst[31]}}, inst[19:12], inst[20], inst[30:25], inst[24:21], 1'b0};
      `STORE: imm = {{21{inst[31]}}, inst[30:25], inst[11:7]};
      default: imm = 32'b0;
    endcase
  end
endmodule
