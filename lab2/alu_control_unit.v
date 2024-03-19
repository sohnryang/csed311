module alu_control_unit (
    input  [16:0] part_of_inst,
    output [ 3:0] alu_op
);
  wire [6:0] func7 = part_of_inst[16:10];
  wire [2:0] func3 = part_of_inst[9:7];
  wire [6:0] opcode = part_of_inst[6:0];
endmodule
