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
  /***** Register declarations *****/
  // You need to modify the width of registers
  // In addition, 
  // 1. You might need other pipeline registers that are not described below
  // 2. You might not need registers described below
  /***** IF/ID pipeline registers *****/
  reg IF_ID_inst;  // will be used in ID stage
  /***** ID/EX pipeline registers *****/
  // From the control unit
  reg ID_EX_alu_op;  // will be used in EX stage
  reg ID_EX_alu_src;  // will be used in EX stage
  reg ID_EX_mem_write;  // will be used in MEM stage
  reg ID_EX_mem_read;  // will be used in MEM stage
  reg ID_EX_mem_to_reg;  // will be used in WB stage
  reg ID_EX_reg_write;  // will be used in WB stage
  // From others
  reg ID_EX_rs1_data;
  reg ID_EX_rs2_data;
  reg ID_EX_imm;
  reg ID_EX_ALU_ctrl_unit_input;
  reg ID_EX_rd;

  /***** EX/MEM pipeline registers *****/
  // From the control unit
  reg EX_MEM_mem_write;  // will be used in MEM stage
  reg EX_MEM_mem_read;  // will be used in MEM stage
  reg EX_MEM_is_branch;  // will be used in MEM stage
  reg EX_MEM_mem_to_reg;  // will be used in WB stage
  reg EX_MEM_reg_write;  // will be used in WB stage
  // From others
  reg EX_MEM_alu_out;
  reg EX_MEM_dmem_data;
  reg EX_MEM_rd;

  /***** MEM/WB pipeline registers *****/
  // From the control unit
  reg MEM_WB_mem_to_reg;  // will be used in WB stage
  reg MEM_WB_reg_write;  // will be used in WB stage
  // From others
  reg MEM_WB_mem_to_reg_src_1;
  reg MEM_WB_mem_to_reg_src_2;
  reg MEM_WB_rd;

  // ---------- Update program counter ----------
  // PC must be updated on the rising edge (positive edge) of the clock.
  PC pc (
      .reset     (),  // input (Use reset to initialize PC. Initial value must be 0)
      .clk       (),  // input
      .next_pc   (),  // input
      .current_pc()   // output
  );

  // ---------- Instruction Memory ----------
  InstMemory imem (
      .reset(),  // input
      .clk  (),  // input
      .addr (),  // input
      .dout ()   // output
  );

  // Update IF/ID pipeline registers here
  always @(posedge clk) begin
    if (reset) begin
    end else begin
    end
  end

  // ---------- Register File ----------
  RegisterFile reg_file (
      .reset       (),          // input
      .clk         (),          // input
      .rs1         (),          // input
      .rs2         (),          // input
      .rd          (),          // input
      .rd_din      (),          // input
      .write_enable(),          // input
      .rs1_dout    (),          // output
      .rs2_dout    (),          // output
      .print_reg   (print_reg)
  );


  // ---------- Control Unit ----------
  ControlUnit ctrl_unit (
      .part_of_inst(),  // input
      .mem_read    (),  // output
      .mem_to_reg  (),  // output
      .mem_write   (),  // output
      .alu_src     (),  // output
      .write_enable(),  // output
      .pc_to_reg   (),  // output
      .alu_op      (),  // output
      .is_ecall    ()   // output (ecall inst)
  );

  // ---------- Immediate Generator ----------
  wire imm_gen_output;

  ImmediateGenerator imm_gen (
      .part_of_inst(),  // input
      .imm_gen_out (imm_gen_output)   // output
  );

  // Update ID/EX pipeline registers here
  always @(posedge clk) begin
    if (reset) begin
    end else begin
    end
  end

  // ---------- ALU Control Unit ----------
  ALUControlUnit alu_ctrl_unit (
      .part_of_inst(),  // input
      .alu_op      ()   // output
  );

  // ---------- ALU ----------
  ALU alu (
      .alu_op    (),  // input
      .alu_in_1  (alu_in_1_forwarded_value),  // input  
      .alu_in_2  (alu_in_2_input),  // input
      .alu_result(),  // output
      .alu_zero  ()   // output
  );

  // ---------- ALU in_2 from IMM or REG ----------
  wire alu_in_2_input;
  mux32bit_2x1 mux_alu_in_2_select (
      .mux_in_0(alu_in_2_forwarded_value),  // alu_in_2_forward_mux.mux_out
      .mux_in_1(imm_gen_output),            // imm_gen.imm_gen_out -> 
      .sel(),                               // (control unit) -> 
      .mux_out(alu_in_2_input)              // -> alu.alu_in_2
  );
  


  // ----------- ALU input multiplexer (For Forwarding) -----------
  wire [31:0] alu_in_1_forwarded_value;
  wire [31:0] alu_in_2_forwarded_value;

  mux32bit_2x1 alu_in_1_forward_mux(
    .mux_in_0(ID_EX_rs1_data),          // rs1_data @ ID/EX ->
    .mux_in_1(rs1_hazard_value),        // rs1_hzd_detection_unit.value -> 
    .sel(rs1_is_hazard),                // rs1_hzd_detection_unit.is_hazardous -> 
    .mux_out(alu_in_1_forwarded_value)  // -> alu.alu_in_1
  );
  
  mux32bit_2x1 alu_in_2_forward_mux(
    .mux_in_0(ID_EX_rs2_data),          // rs2_data @ ID/EX -> 
    .mux_in_1(rs2_hazard_value),        // rs2_hzd_detection_unit.value -> 
    .sel(rs2_is_hazard),                // rs2_hzd_detection_unit.is_hazardous -> 
    .mux_out(alu_in_2_forwarded_value)  // -> mux_alu_in_2_select.mux_in_0
  );

  // Update EX/MEM pipeline registers here
  always @(posedge clk) begin
    if (reset) begin
    end else begin
    end
  end

  // ---------- Data Memory ----------
  DataMemory dmem (
      .reset    (),  // input
      .clk      (),  // input
      .addr     (),  // input
      .din      (),  // input
      .mem_read (),  // input
      .mem_write(),  // input
      .dout     ()   // output
  );

  // Update MEM/WB pipeline registers here
  always @(posedge clk) begin
    if (reset) begin
    end else begin
    end
  end

  // ---------- Hazard Detection Unit ----------
  wire [31:0] rs1_hazard_value;
  wire [31:0] rs2_hazard_value;
  wire rs1_is_hazard;
  wire rs2_is_hazard;
  
  HazardDetectionUnit rs1_hzd_detection_unit(
    .clk(clk),
    .reset(reset),
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

  HazardDetectionUnit rs2_hzd_detection_unit(
    .clk(clk),
    .reset(reset),
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
