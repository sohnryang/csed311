// Submit this file with other files you created.
// Do not touch port declarations of the module 'CPU'.

// Guidelines
// 1. It is highly recommened to `define opcodes and something useful.
// 2. You can modify modules (except InstMemory, DataMemory, and RegisterFile)
// (e.g., port declarations, remove modules, define new modules, ...)
// 3. You might need to describe combinational logics to drive them into the module (e.g., mux, and, or, ...)
// 4. `include files if required

module cpu (
    input         reset,           // positive reset signal
    input         clk,             // clock signal
    output        is_halted,       // Whehther to finish simulation
    output [31:0] print_reg[0:31]
);  // Whehther to finish simulation
  /***** Wire declarations *****/
  // ---------- Update program counter ----------
  // PC must be updated on the rising edge (positive edge) of the clock.
  wire pc_write_enable;
  wire [31:0] pc_next_pc;
  wire [31:0] pc_current_pc;
  PC pc (
      .reset(reset),  // input (Use reset to initialize PC. Initial value must be 0)
      .clk(clk),  // input
      .write_enable(pc_write_enable),
      .next_pc(pc_next_pc),  // input
      .current_pc(pc_current_pc)  // output
  );

  wire [31:0] branch_predictor_predicted_pc;
  assign branch_predictor_predicted_pc = pc_current_pc + 4;

  // ---------- Instruction Memory ----------
  wire [31:0] imem_dout;
  InstMemory imem (
      .reset(reset),  // input
      .clk(clk),  // input
      .addr(pc_current_pc),  // input
      .dout(imem_dout)  // output
  );

  // Update IF/ID pipeline registers here
  wire IF_ID_reg_write_enable;
  wire [31:0] IF_ID_reg_inst_out;
  wire [31:0] IF_ID_reg_pc;
  IFIDRegister if_id_reg (
      .clk  (clk),
      .reset(reset),

      .write_enable(IF_ID_reg_write_enable),

      .inst_in(imem_dout),
      .pc_in  (pc_current_pc),

      .inst_out(IF_ID_reg_inst_out),
      .pc(IF_ID_reg_pc)
  );

  // ---------- Control Unit ----------
  wire ctrl_unit_wb_enable;
  wire ctrl_unit_mem_enable;
  wire ctrl_unit_mem_write;
  wire ctrl_unit_op1_pc;
  wire ctrl_unit_op2_imm;
  wire ctrl_unit_is_ecall;
  wire ctrl_unit_rs2_used;
  wire ctrl_unit_ex_forwardable;
  wire ctrl_unit_is_branch;
  wire ctrl_unit_is_rd_to_pc;
  ControlUnit ctrl_unit (
      .opcode        (IF_ID_reg_inst_out[6:0]),   // input
      .wb_enable     (ctrl_unit_wb_enable),
      .mem_enable    (ctrl_unit_mem_enable),
      .mem_write     (ctrl_unit_mem_write),
      .op1_pc        (ctrl_unit_op1_pc),
      .op2_imm       (ctrl_unit_op2_imm),
      .is_ecall      (ctrl_unit_is_ecall),
      .rs2_used      (ctrl_unit_rs2_used),
      .ex_forwardable(ctrl_unit_ex_forwardable),
      .is_branch     (ctrl_unit_is_branch),
      .is_rd_to_pc   (ctrl_unit_is_rd_to_pc)
  );

  wire [4:0] rs1_mux_mux_out;
  MUX2X1 #(
      .WIDTH(5)
  ) rs1_mux (
      .mux_in_0(IF_ID_reg_inst_out[19:15]),
      .mux_in_1(5'd17),
      .sel(ctrl_unit_is_ecall),
      .mux_out(rs1_mux_mux_out)
  );

  // ---------- Register File ----------
  wire [31:0] reg_file_rd_din;
  wire reg_file_write_enable;
  wire [4:0] reg_file_rd;
  wire [31:0] reg_file_rs1_dout;
  wire [31:0] reg_file_rs2_dout;
  RegisterFile reg_file (
      .reset       (reset),                      // input
      .clk         (clk),                        // input
      .rs1         (rs1_mux_mux_out),            // input
      .rs2         (IF_ID_reg_inst_out[24:20]),  // input
      .rd          (reg_file_rd),                // input
      .rd_din      (reg_file_rd_din),            // input
      .write_enable(reg_file_write_enable),      // input
      .rs1_dout    (reg_file_rs1_dout),          // output
      .rs2_dout    (reg_file_rs2_dout),          // output
      .print_reg   (print_reg)
  );

  wire ecall_unit_is_halted;
  EcallUnit ecall_unit (
      .is_ecall (ctrl_unit_is_ecall),
      .x17_data (reg_file_rs1_dout),
      .is_halted(ecall_unit_is_halted)
  );

  // ---------- Immediate Generator ----------
  wire [31:0] imm_gen_imm;
  ImmediateGenerator imm_gen (
      .inst(IF_ID_reg_inst_out),  // input
      .imm(imm_gen_imm)  // output
  );

  // ---------- Hazard Detection Unit ----------
  wire rs1_hdu_is_hazardous;
  wire rs2_hdu_is_hazardous;

  HazardDetectionUnit rs1_hdu (
      .enable(~ctrl_unit_op1_pc),
      .rs_id(rs1_mux_mux_out),
      .ex_mem_read(ID_EX_reg_mem_enable & ~ID_EX_reg_mem_write),
      .ex_rd_id(ID_EX_reg_rd_id),
      .is_hazardous(rs1_hdu_is_hazardous)
  );

  HazardDetectionUnit rs2_hdu (
      .enable(ctrl_unit_rs2_used),
      .rs_id(IF_ID_reg_inst_out[24:20]),
      .ex_mem_read(ID_EX_reg_mem_enable & ~ID_EX_reg_mem_write),
      .ex_rd_id(ID_EX_reg_rd_id),
      .is_hazardous(rs2_hdu_is_hazardous)
  );

  wire ecall_hdu_is_hazardous;
  EcallHazardDetectionUnit ecall_hdu (
      .enable(ctrl_unit_is_ecall),
      .ex_reg_write(ID_EX_reg_wb_enable),
      .ex_rd_id(ID_EX_reg_rd_id),
      .mem_reg_write(EX_MEM_reg_wb_enable),
      .mem_rd_id(EX_MEM_reg_rd_id),
      .is_hazardous(ecall_hdu_is_hazardous)
  );

  wire is_hazardous;
  assign is_hazardous = rs1_hdu_is_hazardous || rs2_hdu_is_hazardous || ecall_hdu_is_hazardous;
  assign pc_write_enable = ~is_hazardous;
  assign IF_ID_reg_write_enable = ~is_hazardous;

  // Update ID/EX pipeline registers here
  wire ID_EX_reg_wb_enable;
  wire ID_EX_reg_mem_enable;
  wire ID_EX_reg_mem_write;
  wire ID_EX_reg_op1_pc;
  wire ID_EX_reg_op2_imm;
  wire ID_EX_reg_is_halted;
  wire ID_EX_reg_ex_forwardable;
  wire ID_EX_reg_valid;
  wire ID_EX_reg_is_branch;
  wire ID_EX_reg_is_rd_to_pc;
  wire [31:0] ID_EX_reg_rs1;
  wire [31:0] ID_EX_reg_rs2;
  wire [4:0] ID_EX_reg_rs1_id;
  wire [4:0] ID_EX_reg_rs2_id;
  wire [4:0] ID_EX_reg_rd_id;
  wire [31:0] ID_EX_reg_inst;
  wire [31:0] ID_EX_reg_imm;
  wire [31:0] ID_EX_reg_pc;
  IDEXRegister id_ex_reg (
      .clk  (clk),
      .reset(reset),

      .wb_enable_in(ctrl_unit_wb_enable & ~is_hazardous),
      .mem_enable_in(ctrl_unit_mem_enable),
      .mem_write_in(ctrl_unit_mem_write & ~is_hazardous),
      .op1_pc_in(ctrl_unit_op1_pc),
      .op2_imm_in(ctrl_unit_op2_imm),
      .is_halted_in(ecall_unit_is_halted & ~is_hazardous),
      .ex_forwardable_in(ctrl_unit_ex_forwardable & ~is_hazardous),
      .valid_in(~ctrl_hdu_is_hazardous),
      .is_branch_in(ctrl_unit_is_branch),
      .is_rd_to_pc_in(ctrl_unit_is_rd_to_pc),

      .rs1_in(reg_file_rs1_dout),
      .rs2_in(reg_file_rs2_dout),
      .rs1_id_in(rs1_mux_mux_out),
      .rs2_id_in(IF_ID_reg_inst_out[24:20]),
      .rd_id_in(IF_ID_reg_inst_out[11:7]),
      .inst_in(IF_ID_reg_inst_out),
      .imm_in(imm_gen_imm),
      .pc_in(IF_ID_reg_pc),

      .wb_enable(ID_EX_reg_wb_enable),
      .mem_enable(ID_EX_reg_mem_enable),
      .mem_write(ID_EX_reg_mem_write),
      .op1_pc(ID_EX_reg_op1_pc),
      .op2_imm(ID_EX_reg_op2_imm),
      .is_halted(ID_EX_reg_is_halted),
      .ex_forwardable(ID_EX_reg_ex_forwardable),
      .valid(ID_EX_reg_valid),
      .is_branch(ID_EX_reg_is_branch),
      .is_rd_to_pc(ID_EX_reg_is_rd_to_pc),

      .rs1(ID_EX_reg_rs1),
      .rs2(ID_EX_reg_rs2),
      .rs1_id(ID_EX_reg_rs1_id),
      .rs2_id(ID_EX_reg_rs2_id),
      .rd_id(ID_EX_reg_rd_id),
      .inst(ID_EX_reg_inst),
      .imm(ID_EX_reg_imm),
      .pc(ID_EX_reg_pc)
  );

  // ---------- ALU Control Unit ----------
  wire [3:0] alu_ctrl_unit_alu_op;
  ALUControlUnit alu_ctrl_unit (
      .part_of_inst({ID_EX_reg_inst[31:25], ID_EX_reg_inst[14:12], ID_EX_reg_inst[6:0]}),  // input
      .alu_op      (alu_ctrl_unit_alu_op)                                                  // output
  );

  wire rs1_fwd_is_forward;
  wire [31:0] rs1_fwd_forwarded_value;
  ForwardingUnit rs1_fwd (
      .rs_id(ID_EX_reg_rs1_id),
      .ex_forwardable(EX_MEM_reg_ex_forwardable),
      .ex_rd_id(EX_MEM_reg_rd_id),
      .ex_rd(EX_MEM_reg_alu_output),
      .mem_wb_enable(MEM_WB_reg_wb_enable),
      .mem_rd_id(MEM_WB_reg_rd_id),
      .mem_rd(MEM_WB_reg_rd),

      .is_forward(rs1_fwd_is_forward),
      .forwarded_value(rs1_fwd_forwarded_value)
  );

  wire [31:0] rs1_fwd_mux_mux_out;
  MUX2X1 rs1_fwd_mux (
      .mux_in_0(ID_EX_reg_rs1),
      .mux_in_1(rs1_fwd_forwarded_value),
      .sel(rs1_fwd_is_forward),
      .mux_out(rs1_fwd_mux_mux_out)
  );

  wire [31:0] op1_mux_mux_out;
  MUX2X1 op1_mux (
      .mux_in_0(rs1_fwd_mux_mux_out),
      .mux_in_1(ID_EX_reg_pc),
      .sel(ID_EX_reg_op1_pc),
      .mux_out(op1_mux_mux_out)
  );

  wire rs2_fwd_is_forward;
  wire [31:0] rs2_fwd_forwarded_value;
  ForwardingUnit rs2_fwd (
      .rs_id(ID_EX_reg_rs2_id),
      .ex_forwardable(EX_MEM_reg_ex_forwardable),
      .ex_rd_id(EX_MEM_reg_rd_id),
      .ex_rd(EX_MEM_reg_alu_output),
      .mem_wb_enable(MEM_WB_reg_wb_enable),
      .mem_rd_id(MEM_WB_reg_rd_id),
      .mem_rd(MEM_WB_reg_rd),

      .is_forward(rs2_fwd_is_forward),
      .forwarded_value(rs2_fwd_forwarded_value)
  );

  wire [31:0] rs2_fwd_mux_mux_out;
  MUX2X1 rs2_fwd_mux (
      .mux_in_0(ID_EX_reg_rs2),
      .mux_in_1(rs2_fwd_forwarded_value),
      .sel(rs2_fwd_is_forward),
      .mux_out(rs2_fwd_mux_mux_out)
  );

  // ---------- ALU in_2 from IMM or REG ----------
  wire [31:0] alu_in_2_input;
  MUX2X1 mux_alu_in_2_select (
      .mux_in_0(rs2_fwd_mux_mux_out),  // alu_in_2_forward_mux.mux_out
      .mux_in_1(ID_EX_reg_imm),        // imm_gen.imm_gen_out -> 
      .sel     (ID_EX_reg_op2_imm),    // (control unit) -> 
      .mux_out (alu_in_2_input)        // -> alu.alu_in_2
  );

  // ---------- ALU ----------
  wire [31:0] alu_alu_result;
  ALU alu (
      .alu_op    (alu_ctrl_unit_alu_op),  // input
      .alu_in_1  (op1_mux_mux_out),       // input  
      .alu_in_2  (alu_in_2_input),        // input
      .alu_result(alu_alu_result)         // output
  );

  wire [31:0] pc_gen_next_pc;
  PCGenerator pc_gen (
      .is_branch(ID_EX_reg_is_branch),
      .is_rd_to_pc(ID_EX_reg_is_rd_to_pc),
      .current_pc(ID_EX_reg_pc),
      .rs1_data(ID_EX_reg_rs1),
      .imm(ID_EX_reg_imm),
      .alu_result(alu_alu_result),

      .next_pc(pc_gen_next_pc)
  );

  wire ctrl_hdu_is_hazardous;
  ControlHazardDetectionUnit ctrl_hdu (
      .resolved_pc (pc_gen_next_pc),
      .predicted_pc(IF_ID_reg_pc),

      .is_hazardous(ctrl_hdu_is_hazardous)
  );

  MUX2X1 mux_next_pc (
      .mux_in_0(branch_predictor_predicted_pc),
      .mux_in_1(pc_gen_next_pc),
      .sel(ctrl_hdu_is_hazardous),
      .mux_out(pc_next_pc)
  );

  // Update EX/MEM pipeline registers here
  wire EX_MEM_reg_wb_enable;
  wire EX_MEM_reg_mem_enable;
  wire EX_MEM_reg_mem_write;
  wire EX_MEM_reg_is_halted;
  wire EX_MEM_reg_ex_forwardable;
  wire [31:0] EX_MEM_reg_alu_output;
  wire [31:0] EX_MEM_reg_rs2;
  wire [4:0] EX_MEM_reg_rd_id;
  EXMEMRegister ex_mem_reg (
      .clk  (clk),
      .reset(reset),

      .wb_enable_in(ID_EX_reg_wb_enable & ID_EX_reg_valid),
      .mem_enable_in(ID_EX_reg_mem_enable & ID_EX_reg_valid),
      .mem_write_in(ID_EX_reg_mem_write),
      .is_halted_in(ID_EX_reg_is_halted & ID_EX_reg_valid),
      .ex_forwardable_in(ID_EX_reg_ex_forwardable & ID_EX_reg_valid),

      .alu_output_in(alu_alu_result),
      .rs2_in(rs2_fwd_mux_mux_out),
      .rd_id_in(ID_EX_reg_rd_id),

      .wb_enable(EX_MEM_reg_wb_enable),
      .mem_enable(EX_MEM_reg_mem_enable),
      .mem_write(EX_MEM_reg_mem_write),
      .is_halted(EX_MEM_reg_is_halted),
      .ex_forwardable(EX_MEM_reg_ex_forwardable),

      .alu_output(EX_MEM_reg_alu_output),
      .rs2(EX_MEM_reg_rs2),
      .rd_id(EX_MEM_reg_rd_id)
  );

  // ---------- Data Memory ----------
  wire [31:0] dmem_dout;
  DataMemory dmem (
      .reset    (reset),                  // input
      .clk      (clk),                    // input
      .addr     (EX_MEM_reg_alu_output),  // input
      .din      (EX_MEM_reg_rs2),         // input
      .mem_read (EX_MEM_reg_mem_enable),  // input
      .mem_write(EX_MEM_reg_mem_write),   // input
      .dout     (dmem_dout)               // output
  );

  // Update MEM/WB pipeline registers here
  wire [31:0] rd_mux_mux_out;
  MUX2X1 rd_mux (
      .mux_in_0(EX_MEM_reg_alu_output),
      .mux_in_1(dmem_dout),
      .sel(EX_MEM_reg_mem_enable),
      .mux_out(rd_mux_mux_out)
  );

  wire MEM_WB_reg_wb_enable;
  wire MEM_WB_reg_is_halted;
  wire [4:0] MEM_WB_reg_rd_id;
  wire [31:0] MEM_WB_reg_rd;
  MEMWBRegister mem_wb_reg (
      .clk  (clk),
      .reset(reset),

      .wb_enable_in(EX_MEM_reg_wb_enable),
      .is_halted_in(EX_MEM_reg_is_halted),

      .rd_id_in(EX_MEM_reg_rd_id),
      .rd_in(rd_mux_mux_out),

      .wb_enable(MEM_WB_reg_wb_enable),
      .is_halted(is_halted),

      .rd_id(MEM_WB_reg_rd_id),
      .rd(MEM_WB_reg_rd)
  );
  assign reg_file_write_enable = MEM_WB_reg_wb_enable;
  assign reg_file_rd = MEM_WB_reg_rd_id;
  assign reg_file_rd_din = MEM_WB_reg_rd;
endmodule
