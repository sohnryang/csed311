`include "branchpredictor_def.v"

module BranchPredictor (
    input clk,
    input rst,
    // ---------- Input for Async. Branch prediction ----------
    input [31:0] current_pc,

    // ---------- Input for Sync. Branch predictor update ----------
    input        update_pred,          // When update
    input [31:0] branch_inst_address,  // Previous branch instruction taken address to update PHT
    input [31:0] resolved_next_pc,     // Actual PC will be
    input        predictor_wrong,      // Predictor Wrong?

    // ---------- Output for Branch prediction ----------
    output reg [31:0] predicted_pc  // Predicted PC
);
  // ---------- Global Branch History Register ----------
  reg  [ `BHSR_WIDTH - 1:0] bhsr;  // 5-bit BHSR 
  // ---------- Pattern History Table ----------
  reg  [               1:0] pht                                  [`BHSR_ENTRIES - 1:0];
  // ---------- Branch Target Buffer ----------
  reg  [31 - `BHSR_WIDTH:0] btb_tag_tbl                          [`BHSR_ENTRIES - 1:0];
  reg  [              31:0] btb_target_tbl                       [`BHSR_ENTRIES - 1:0];

  // ---------- Wire for Async. Branch predicting ----------
  wire [ `BHSR_WIDTH - 1:0] pc_lsb;  // LSB of current PC
  wire [31 - `BHSR_WIDTH:0] pc_msb;  // MSB of current PC
  wire [ `BHSR_WIDTH - 1:0] pht_index;  // XORed PC with BHSR of 

  // ---------- Wire for Sync. Branch predictor updating ----------
  reg  [ `BHSR_WIDTH - 1:0] update_pc_lsb;
  reg  [31 - `BHSR_WIDTH:0] update_pc_msb;
  reg  [ `BHSR_WIDTH - 1:0] update_pht_index;

  // ---------- Async. Branch Prediction ----------
  assign pc_msb = current_pc[31 : `BHSR_WIDTH];
  assign pc_lsb = current_pc[`BHSR_WIDTH-1:0];
  assign pht_index = pc_lsb ^ bhsr;

  always @(*) begin
    if ((pht[pht_index] >= `WEAK_TAKEN) && (btb_tag_tbl[pc_lsb] == pc_msb)) begin // Tag matches, Likely to take branch
      $display("Predict  T to %x -> %x (%x), because PHT[%x] = %x with HISTORY[%b] and TAG MATCH [%x = %x]", current_pc, btb_target_tbl[pc_lsb], pc_lsb, pht_index, pht[pht_index], bhsr, btb_tag_tbl[pc_lsb], pc_msb);
      assign predicted_pc = btb_target_tbl[pc_lsb];
    end else begin
      $display("Predict NT to %x -> %x (%x), because PHT[%x] = %x with HISTORY[%b] and TAG MATCH [%x = %x]", current_pc, current_pc + 4, pc_lsb, pht_index, pht[pht_index], bhsr, btb_tag_tbl[pc_lsb], pc_msb);
      assign predicted_pc = current_pc + 4;
    end
  end


  // ---------- Sync. Branch Predictor state update ----------
  integer i;
  always @(posedge clk) begin
    if (rst) begin
      bhsr <= `BHSR_WIDTH'b0;
      for (i = 0; i < `BHSR_ENTRIES; i = i + 1) begin
        pht[i] <= 2'b00;
        btb_tag_tbl[i] <= 0;
        btb_target_tbl[i] <= 0;
      end
    end

    if (update_pred && predictor_wrong) begin
      update_pc_msb <= branch_inst_address[31:`BHSR_WIDTH];
      update_pc_lsb <= branch_inst_address[`BHSR_WIDTH-1:0];
      update_pht_index <= update_pc_lsb ^ bhsr;


      /* Updating 2-bit saturatrion counter FSM state */
      if (predictor_wrong == 1'b1) begin  // Predictor Correct
        if (predicted_pc + 4 == resolved_next_pc) begin  // Pred: NT, Actual: NT
          pht[update_pht_index] <= (pht[update_pht_index] == `STRONG_NOT_TAKEN ? `STRONG_NOT_TAKEN : pht[update_pht_index] - 1); // Decrease counter
          btb_tag_tbl[update_pc_lsb] <= update_pc_msb;
          btb_target_tbl[update_pc_lsb] <= resolved_next_pc;
          bhsr <= (bhsr << 1 | `BHSR_WIDTH'b0);
          $display("(%x -> %x) P NT == R NT, PHT[%x] = %x with HISTORY = [%b] and TARGET[%x] = %x",predicted_pc, resolved_next_pc, update_pht_index, pht[update_pht_index], bhsr, update_pc_lsb, btb_target_tbl[update_pc_lsb]);
        end else begin  // Pred: T, Actual: T
          pht[update_pht_index] <= (pht[update_pht_index] == `STRONG_TAKEN ? `STRONG_TAKEN : pht[update_pht_index] + 1); // Increase Counter
          btb_tag_tbl[update_pc_lsb] <= update_pc_msb;
          btb_target_tbl[update_pc_lsb] <= resolved_next_pc;
          bhsr <= (bhsr << 1 | `BHSR_WIDTH'b1);
          $display("(%x -> %x) P  T == R  T, PHT[%x] = %x with HISTORY = [%b] and TARGET[%x] = %x",predicted_pc, resolved_next_pc, update_pht_index, pht[update_pht_index], bhsr, update_pc_lsb, btb_target_tbl[update_pc_lsb]);
        end
      end else begin  // Predictor Wrong
        if (predicted_pc + 4 == resolved_next_pc) begin  // Predict: NT, Actual: T
          pht[update_pht_index] <= (pht[update_pht_index] == `STRONG_TAKEN ? `STRONG_TAKEN : pht[update_pht_index] + 1); // Increase Counter
          btb_tag_tbl[update_pc_lsb] <= update_pc_msb;
          btb_target_tbl[update_pc_lsb] <= resolved_next_pc;
          bhsr <= (bhsr << 1 | `BHSR_WIDTH'b1);
          $display("(%x -> %x) P NT != R  T, PHT[%x] = %x with HISTORY = [%b] and TARGET[%x] = %x",predicted_pc, resolved_next_pc, update_pht_index, pht[update_pht_index], bhsr, update_pc_lsb, btb_target_tbl[update_pc_lsb]);
        end else begin  // Pred: T, Actual: NT
          pht[update_pht_index] <= (pht[update_pht_index] == `STRONG_NOT_TAKEN ? `STRONG_NOT_TAKEN : pht[update_pht_index] - 1); // Decrease counter
          btb_tag_tbl[update_pc_lsb] <= update_pc_msb;
          btb_target_tbl[update_pc_lsb] <= resolved_next_pc;
          bhsr <= (bhsr << 1 | `BHSR_WIDTH'b0);
          $display("(%x -> %x) P  T != R NT, PHT[%x] = %x with HISTORY = [%b] and TARGET[%x] = %x",predicted_pc, resolved_next_pc, update_pht_index, pht[update_pht_index], bhsr, update_pc_lsb, btb_target_tbl[update_pc_lsb]);
        end
      end
    end
  end
endmodule
