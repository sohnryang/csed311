`include "branchpredictor_def.v"

module BranchPredictor (
    input  [31:0] current_pc,
    output [31:0] predicted_pc,

    input update_pred,          // When update
    input actually_taken,       // Actually taken data
    input [31:0] taken_address  // Actually taken addr
);
  // ---------- Global Branch History Register ----------
  reg [`BHSR_WIDTH - 1:0] bhsr;       // 10-bit BHSR 
  // ---------- Pattern History Table ----------
  reg [`BHSR_ENTRIES - 1:0] pht[1:0];
  // ---------- Branch Target Buffer ----------
  reg [`BHSR_ENTRIES - 1:0] btb_tag_tbl[31 - `BHSR_WIDTH: 0];
  reg [`BHSR_ENTRIES - 1:0] btb_target_tbl[31:0];

  wire [`BHSR_WIDTH - 1:0] pc_lsb;    // LSB of current PC
  wire [31 - `BHSR_WIDTH:0] pc_msb;   // MSB of current PC
  wire [`BHSR_WIDTH - 1:0] pht_index; // XORed PC with BHSR of 

  assign pc_msb = current_pc[31 : `BHSR_WIDTH];
  assign pc_lsb = current_pc[`BHSR_WIDTH - 1: 0];
  assign pht_index = pc_lsb ^ bhsr;

  if ((pht[pht_index] >= `WEAK_NOT_TAKEN) && (btb_tag_tbl[pc_lsb] == msb_pc)) begin // Tag matches, Likely to take branch
    assign predicted_pc = btb_target_tbl[pc_lsb];
  end else begin
    assign predicted_pc = current_pc + 4;
  end
endmodule
