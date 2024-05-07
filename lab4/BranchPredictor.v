`include "branchpredictor_def.v"

module BranchPredictor (
    input clk,
    input rst,
    // ---------- Input for Async. Branch prediction ----------
    input  [31:0] current_pc,

    // ---------- Input for Sync. Branch predictor update ----------
    input update_pred,                 // When update
    input [31:0] branch_inst_address,  // Previous branch instruction taken address to update PHT
    input [31:0] resolved_next_pc,     // Actual PC will be
    input predictor_wrong,             // Predictor Wrong?

    // ---------- Output for Branch prediction ----------
    output [31:0] predicted_pc,        // Predicted PC
);

  // ---------- Global Branch History Register ----------
  reg [`BHSR_WIDTH - 1:0] bhsr;       // 10-bit BHSR 
  // ---------- Pattern History Table ----------
  reg [`BHSR_ENTRIES - 1:0] pht[1:0];
  // ---------- Branch Target Buffer ----------
  reg [`BHSR_ENTRIES - 1:0] btb_tag_tbl[31 - `BHSR_WIDTH: 0];
  reg [`BHSR_ENTRIES - 1:0] btb_target_tbl[31:0];

  // ---------- Wire for Async. Branch predicting ----------
  wire [`BHSR_WIDTH - 1: 0] pc_lsb;    // LSB of current PC
  wire [31 - `BHSR_WIDTH:0] pc_msb;   // MSB of current PC
  wire [`BHSR_WIDTH - 1: 0] pht_index; // XORed PC with BHSR of 

  // ---------- Wire for Sync. Branch predictor updating ----------
  wire [`BHSR_WIDTH - 1: 0] update_pc_lsb;
  wire [31 - `BHSR_WIDTH:0] update_pc_msb;
  wire [`BHSR_WIDTH - 1: 0] update_pht_index;

  // ---------- Async. Branch Prediction ----------
  assign pc_msb = current_pc[31 : `BHSR_WIDTH];
  assign pc_lsb = current_pc[`BHSR_WIDTH - 1: 0];
  assign pht_index = pc_lsb ^ bhsr;

  if ((pht[pht_index] >= `WEAK_NOT_TAKEN) && (btb_tag_tbl[pc_lsb] == msb_pc)) begin // Tag matches, Likely to take branch
    assign predicted_pc = btb_target_tbl[pc_lsb];
  end else begin
    assign predicted_pc = current_pc + 4;
  end

  // ---------- Sync. Branch Predictor state update ----------
  always @(posedge clk) begin
    if (rst) begin
    end

    assign update_pc_msb = branch_inst_address[31: `BHSR_WIDTH];
    assign update_pc_lsb = branch_inst_address[`BHSR_WIDTH - 1: 0];
    assign update_pht_index = updtae_pc_lsb ^ bhsr;

    /* Updating 2-bit saturatrion counter FSM state */
    if(predictor_wrong == 1'b0) begin   // Predictor Correct
      if(branch_inst_address + 4 == resolved_next_pc) begin // Pred: NT, Actual: NT
        pht[update_pht_index] = (pht[update_pht_index] == `STRONG_NOT_TAKEN ? `STRONG_NOT_TAKEN : pht[update_pht_index] - 1); // Decrease counter
        btb_tag_tbl[update_pht_index] = update_pc_msb;
        btb_target_tbl[update_pht_index] = resolved_next_pc;
      end
      else begin  // Pred: T, Actual: T
        pht[update_pht_index] = (pht[update_pht_index] == `STRONG_TAKEN ? `STRONG_TAKEN : pht[update_pht_index] + 1); // Increase Counter
        btb_tag_tbl[update_pht_index] = update_pc_msb;
        btb_target_tbl[update_pht_index] = resolved_next_pc;
      end
    end
    else begin  // Predictor Wrong
      if(branch_inst_address + 4 == resolved_next_pc) begin // Predict: NT, Actual: T
        pht[update_pht_index] = (pht[update_pht_index] == `STRONG_TAKEN ? `STRONG_TAKEN : pht[update_pht_index] + 1); // Increase Counter
        btb_tag_tbl[update_pht_index] = update_pc_msb;
        btb_target_tbl[update_pht_index] = resolved_next_pc;
      end
      else begin  // Pred: T, Actual: NT
        pht[update_pht_index] = (pht[update_pht_index] == `STRONG_NOT_TAKEN ? `STRONG_NOT_TAKEN : pht[update_pht_index] - 1); // Decrease counter
        btb_tag_tbl[update_pht_index] = update_pc_msb;
        btb_target_tbl[update_pht_index] = resolved_next_pc;
      end

    assign predicted_pc = 32'h00000000; // NOT returning predicted PC
  end
endmodule
