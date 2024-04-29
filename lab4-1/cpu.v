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
  IFIDRegister if_id_reg (
      .clk  (clk),
      .reset(reset),

      .write_enable(IF_ID_reg_write_enable),
      .inst_in(imem_dout),

      .inst_out(IF_ID_reg_inst_out)
  );

  // ---------- Register File ----------
  wire [31:0] reg_file_rd_din;
  wire reg_file_write_enable;
  wire [31:0] reg_file_rs1_dout;
  wire [31:0] reg_file_rs2_dout;
  RegisterFile reg_file (
      .reset       (reset),                      // input
      .clk         (clk),                        // input
      .rs1         (IF_ID_reg_inst_out[19:15]),  // input
      .rs2         (IF_ID_reg_inst_out[24:20]),  // input
      .rd          (IF_ID_reg_inst_out[11:7]),   // input
      .rd_din      (reg_file_rd_din),            // input
      .write_enable(reg_file_write_enable),      // input
      .rs1_dout    (reg_file_rs1_dout),          // output
      .rs2_dout    (reg_file_rs2_dout),          // output
      .print_reg   (print_reg)
  );

  // ---------- Control Unit ----------
  wire ctrl_unit_wb_enable;
  wire ctrl_unit_mem_enable;
  wire ctrl_unit_mem_write;
  wire ctrl_unit_op2_imm;
  wire ctrl_unit_is_ecall;
  ControlUnit ctrl_unit (
      .opcode    (IF_ID_reg_inst_out[6:0]),  // input
      .wb_enable (ctrl_unit_wb_enable),
      .mem_enable(ctrl_unit_mem_enable),
      .mem_write (ctrl_unit_mem_write),
      .op2_imm   (ctrl_unit_op2_imm),
      .is_ecall  (ctrl_unit_is_ecall)
  );

  MUX2X1 #(
      .WIDTH(5)
  ) rs1_mux (
      .mux_in_0(IF_ID_reg_inst_out[19:15]),
      .mux_in_1(5'd17),
      .sel(ctrl_unit_is_ecall)
  );

  wire ecall_unit_is_halted;
  EcallUnit ecall_unit (
      .is_ecall (ctrl_unit_is_ecall),
      .x17_data (reg_file_rs1_dout),
      .is_halted(ecall_unit_is_halted)
  );

  // ---------- Immediate Generator ----------
  wire [31:0] imm_gem_imm;
  ImmediateGenerator imm_gen (
      .inst(IF_ID_reg_inst_out),  // input
      .imm(imm_gen_imm)  // output
  );

  // Update ID/EX pipeline registers here
  wire [31:0] ID_EX_reg_rs1_in;
  wire [31:0] ID_EX_reg_rs2_in;
  wire [4:0] ID_EX_reg_rd_id_in;
  wire ID_EX_reg_wb_enable;
  wire ID_EX_reg_mem_enable;
  wire ID_EX_reg_mem_write;
  wire ID_EX_reg_op2_imm;
  wire ID_EX_reg_is_halted;
  wire [31:0] ID_EX_reg_rs1;
  wire [31:0] ID_EX_reg_rs2;
  wire [4:0] ID_EX_reg_rd_id;
  IDEXRegister id_ex_reg (
      .clk  (clk),
      .reset(reset),

      .wb_enable_in(ctrl_unit_wb_enable),
      .mem_enable_in(ctrl_unit_mem_enable),
      .mem_write_in(ctrl_unit_mem_write),
      .op2_imm_in(ctrl_unit_op2_imm),
      .is_halted_in(ecall_unit_is_halted),

      .rs1_in  (reg_file_rs1_dout),
      .rs2_in  (reg_file_rs2_dout),
      .rd_id_in(IF_ID_reg_inst_out[11:7]),

      .wb_enable(ID_EX_reg_wb_enable),
      .mem_enable(ID_EX_reg_mem_enable),
      .mem_write(ID_EX_reg_mem_write),
      .op2_imm(ID_EX_reg_op2_imm),
      .is_ecall(ID_EX_reg_is_halted),

      .rs1  (ID_EX_reg_rs1),
      .rs2  (ID_EX_reg_rs2),
      .rd_id(ID_EX_reg_rd_id)
  );

  // ---------- ALU Control Unit ----------
  wire [3:0] alu_ctrl_unit_alu_op;
  ALUControlUnit alu_ctrl_unit (
      .part_of_inst({IR[31:25], IR[14:12], IR[6:0]}),  // input
      .alu_op      (alu_ctrl_unit_alu_op)              // output
  );

  // ---------- ALU ----------
  wire [31:0] alu_alu_result;
  ALU alu (
      .alu_op    (alu_ctrl_unit_alu_op),      // input
      .alu_in_1  (alu_in_1_forwarded_value),  // input  
      .alu_in_2  (alu_in_2_input),            // input
      .alu_result(alu_alu_result)             // output
  );

  // ---------- ALU in_2 from IMM or REG ----------
  wire [31:0] alu_in_2_input;
  MUX2X1 mux_alu_in_2_select (
      .mux_in_0(alu_in_2_forwarded_value),  // alu_in_2_forward_mux.mux_out
      .mux_in_1(imm_gen_output),            // imm_gen.imm_gen_out -> 
      .sel     (ID_EX_reg_op2_imm),         // (control unit) -> 
      .mux_out (alu_in_2_input)             // -> alu.alu_in_2
  );



  // ----------- ALU input multiplexer (For Forwarding) -----------
  wire [31:0] alu_in_1_forwarded_value;
  wire [31:0] alu_in_2_forwarded_value;

  MUX2X1 alu_in_1_forward_mux (
      .mux_in_0(ID_EX_rs1_data),           // rs1_data @ ID/EX ->
      .mux_in_1(rs1_hazard_value),         // rs1_hzd_detection_unit.value -> 
      .sel     (rs1_is_hazard),            // rs1_hzd_detection_unit.is_hazardous -> 
      .mux_out (alu_in_1_forwarded_value)  // -> alu.alu_in_1
  );

  MUX2X1 alu_in_2_forward_mux (
      .mux_in_0(ID_EX_rs2_data),           // rs2_data @ ID/EX -> 
      .mux_in_1(rs2_hazard_value),         // rs2_hzd_detection_unit.value -> 
      .sel     (rs2_is_hazard),            // rs2_hzd_detection_unit.is_hazardous -> 
      .mux_out (alu_in_2_forwarded_value)  // -> alu.alu_in_2
  );

  MUX2X1 alu_in_2_forward_mux (
      .mux_in_0(ID_EX_rs2_data),           // rs2_data @ ID/EX -> 
      .mux_in_1(rs2_hazard_value),         // rs2_hzd_detection_unit.value -> 
      .sel     (rs2_is_hazard),            // rs2_hzd_detection_unit.is_hazardous -> 
      .mux_out (alu_in_2_forwarded_value)  // -> mux_alu_in_2_select.mux_in_0
  );

  // Update EX/MEM pipeline registers here
  wire EX_MEM_reg_wb_enable;
  wire EX_MEM_reg_mem_enable;
  wire EX_MEM_reg_mem_write;
  wire EX_MEM_reg_is_halted;
  wire [31:0] EX_MEM_reg_alu_output;
  wire [31:0] EX_MEM_reg_rs2;
  wire [4:0] EX_MEM_reg_rd_id;
  EXMEMRegister ex_mem_reg (
      .clk  (clk),
      .reset(reset),

      .wb_enable_in (ID_EX_reg_wb_enable),
      .mem_enable_in(ID_EX_reg_mem_enable),
      .mem_write_in (ID_EX_reg_mem_write),
      .is_halted_in (ID_EX_reg_is_halted),

      .alu_output_in(alu_alu_result),
      .rs2_in(ID_EX_reg_rs2),
      .rd_id_in(ID_EX_reg_rd_id),

      .wb_enable (EX_MEM_reg_wb_enable),
      .mem_enable(EX_MEM_reg_mem_enable),
      .mem_write (EX_MEM_reg_mem_write),
      .is_halted (EX_MEM_reg_is_halted),

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
      .is_halted(MEM_WB_reg_is_halted),

      .rd_id(MEM_WB_reg_rd_id),
      .rd(MEM_WB_reg_rd)
  );

  // ---------- Hazard Detection Unit ----------
  wire [31:0] rs1_hazard_value;
  wire [31:0] rs2_hazard_value;
  wire rs1_is_hazard;
  wire rs2_is_hazard;

  HazardDetectionUnit rs1_hzd_detection_unit (
      .id_ex_rs(ID_EX_rs1_data),
      .ex_mem_rd(EX_MEM_rd),
      .ex_mem_reg_write(EX_MEM_reg_write),
      .ex_mem_alu_out(EX_MEM_alu_out),
      .mem_wb_rd(MEM_WB_rd),
      .mem_wb_reg_write(MEM_WB_reg_write),
      .mem_wb_mem_to_reg(MEM_WB_mem_to_reg_src_1),
      .value(rs1_hazard_value),
      .is_hazardous(rs1_is_hazard)
  );

  HazardDetectionUnit rs2_hzd_detection_unit (
      .id_ex_rs(ID_EX_rs2_data),
      .ex_mem_rd(EX_MEM_rd),
      .ex_mem_reg_write(EX_MEM_reg_write),
      .ex_mem_alu_out(EX_MEM_alu_out),
      .mem_wb_rd(MEM_WB_rd),
      .mem_wb_reg_write(MEM_WB_reg_write),
      .mem_wb_mem_to_reg(MEM_WB_mem_to_reg_src_2),
      .value(rs2_hazard_value),
      .is_hazardous(rs2_is_hazard)
  );
endmodule
