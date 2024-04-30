module BranchPredictor (
    input  [31:0] current_pc,
    output [31:0] predicted_pc
);
  assign predicted_pc = current_pc + 4;
endmodule
