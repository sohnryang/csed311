// Submit this file with other files you created.
// Do not touch port declarations of the module 'cpu'.

// Guidelines
// 1. It is highly recommened to `define opcodes and something useful.
// 2. You can modify the module.
// (e.g., port declarations, remove modules, define new modules, ...)
// 3. You might need to describe combinational logics to drive them into the module (e.g., mux, and, or, ...)
// 4. `include files if required
`include "cpu_def.v"

module cpu (
    input         reset,           // positive reset signal
    input         clk,             // clock signal
    output        is_halted,       // Whehther to finish simulation
    output [31:0] print_reg[0:31]
);  // TO PRINT REGISTER VALUES IN TESTBENCH (YOU SHOULD NOT USE THIS)
  /***** Wire declarations *****/

  wire [31:0] instruction;
  wire [3:0] alu_operation;

  wire [31:0] reg_file_read_dout1;
  wire [31:0] reg_file_read_dout2;

  wire [31:0] register_write_data;
  wire [31:0] alu_in2_input;
  wire [31:0] mux_alu_in_2_mux_in_1;

  wire [31:0] alu_output;

  wire [31:0] imm_gen_output_type_i;
  wire [31:0] imm_gen_output_type_s;
  wire [31:0] imm_gen_output_type_b;
  wire [31:0] imm_gen_output_type_u;
  wire [31:0] imm_gen_output_type_j;

  wire [31:0] dmem_output;

  wire [31:0] mux_dmem_output;

  wire control_unit_output[0:`CONTROL_UNIT_LINES_COUNT - 1];

  wire [31:0] current_pc_address;
  wire [31:0] next_pc_address;
  wire [31:0] adjacent_pc_address;
  wire [31:0] adder_offset_pc_address_adder_in_1;
  wire [31:0] added_offset_pc_address;
  wire [31:0] branch_determined_pc_address;

  /***** Register declarations *****/

  // ---------- Update program counter ----------
  // PC must be updated on the rising edge (positive edge) of the clock.
  pc pc (
      .reset(reset),  // input (Use reset to initialize PC. Initial value must be 0)
      .clk(clk),  // input
      .next_pc(next_pc_address),  // MUX_ALU_ADDRESS_SELECT.MUX_OUT -> 
      .current_pc(current_pc_address)   // -> IMEM.ADDR, -> ADDER_ADJACENT_PC_ADDRESS.MUX_IN_0 ->, ADDER_OFFSET_PC_ADDRESS.MUX_IN_0
  );

  // ---------- Instruction Memory ----------
  instruction_memory imem (
      .reset(reset),   // input
      .clk(clk),     // input
      .addr(current_pc_address),    // PC.CURRENT_PC ->
      .dout(instruction)     // output
  );

  // ---------- Register File ----------
  register_file reg_file (
      .reset(reset),  // input
      .clk(clk),  // input
      .rs1(instruction[19:15]),  // input
      .rs2(instruction[24:20]),  // input
      .rd(instruction[11:7]),  // input
      .rd_din(register_write_data),  // MUX_REGISTER_WRITE_DATA_SELECT.MUX_OUT ->
      .write_enable(control_unit_output[`CONTROL_REG_WRITE]),  // CTRL_UNIT -> 
      .rs1_dout(reg_file_read_dout1),  // -> ALU.ALU_IN_1
      .rs2_dout(reg_file_read_dout2),  // -> DMEM.DIN, -> MUX_ALU_IN_2_SELECT.MUX_IN_0
      .print_reg(print_reg)  //DO NOT TOUCH THIS
  );


  // ---------- Control Unit ----------
  control_unit ctrl_unit (
      .part_of_inst(instruction[6:0]),  // input
      .is_jal(control_unit_output[`CONTROL_JAL]),  // -> MUX_BRANCH_SELECT.SEL
      .is_jalr(control_unit_output[`CONTROL_JALR]),  // -> MUX_ALU_ADDRESS_SELECT.SEL
      .branch(control_unit_output[`CONTROL_BRANCH]),  // -> MUX_BRANCH_SELECT.SEL
      .mem_read(control_unit_output[`CONTROL_MEM_READ]),  // -> DMEM.MEM_READ
      .mem_to_reg(control_unit_output[`CONTROL_MEM_TO_REG]),  // -> DMEM_OUT_SELECT.SEL
      .mem_write(control_unit_output[`CONTROL_MEM_WRITE]),  // -> DMEM.MEM_WRITE
      .alu_src(control_unit_output[`CONTROL_ALU_SRC]),  // -> MUX_ALU_IN2_SELECT.SEL
      .write_enable(control_unit_output[`CONTROL_REG_WRITE]),  // -> REG_FILE.WRITE_ENABLE
      .pc_to_reg(control_unit_output[`CONTROL_PC_TO_REG]),     // -> MUX_REGISTER_WRITE_DATA_SELECT.SEL
      .is_ecall(control_unit_output[`CONTROL_IS_ECALL])  // output (ecall inst)
  );

  // ---------- Immediate Generator ----------
  immediate_generator imm_gen (
      .inst(instruction),  // input
      .i_imm(imm_gen_output_type_i),    // (@ I-Imm, Load, JALR) -> MUX_ALU_IN_2_SELECT.MUX_IN_1
      .s_imm(imm_gen_output_type_s),    // (@ Store) -> MUX_ALU_IN_2_SELECT.MUX_IN_1
      .b_imm(imm_gen_output_type_b),    // (@ Branch) -> ADDER_OFFSET_PC_ADDRESS.ADDER_IN_1
      .u_imm(imm_gen_output_type_u),    // (@ Upper Immed.: Not using in given instruction set)
      .j_imm(imm_gen_output_type_j)     // (@ JAL) -> ADDER_OFFSET_PC_ADDRESS.ADDER_IN_1
  );

  // ---------- ALU Control Unit ----------
  alu_control_unit alu_ctrl_unit (
      .part_of_inst({instruction[31:25], instruction[14:12], instruction[6:0]}),  // input
      .alu_op      (alu_operation)                                                // -> ALU.ALU_OP
  );

  // ---------- ALU ----------
  alu alu (
      .alu_op(alu_operation),  // ALU_CTRL_UNIT.ALU_OP ->
      .alu_in_1(reg_file_read_dout1),  // REG_FILE.RS1_DOUT -> 
      .alu_in_2(alu_in2_input),  // MUX_ALU_IN2_SELECT.MUX_OUT -> 
      .alu_result(alu_output)  // -> MUX_ALU_ADDRESS_SELECT.MUX_IN_1, -> DMEM.ADDR, -> MUX_DMEM_OUT_SELECT.MUX_IN_0, -> MUX_BRANCH_SELECT.SEL (as LSB)
  );

  // ---------- Data Memory ----------
  data_memory dmem (
      .reset    (reset),                                    // input
      .clk      (clk),                                      // input
      .addr     (alu_output),                               // ALU.ALU_RESULT -> 
      .din      (reg_file_read_dout2),                      // REG_FILE.RS2_DOUT -> 
      .mem_read (control_unit_output[`CONTROL_MEM_READ]),   // CTRL_UNIT -> 
      .mem_write(control_unit_output[`CONTROL_MEM_WRITE]),  // CTRL_UNIT ->
      .dout     (dmem_output)                               // -> MUX_DMEM_OUT_SELECT.MUX_IN_1
  );

  mux32bit mux_register_write_data_select (
      .mux_in_0(mux_dmem_output),  // MUX_DMEM_OUT.MUX_OUT ->
      .mux_in_1(adjacent_pc_address),  // ADDER_ADJACENT_PC_ADDRESS.ADDER_OUT ->
      .sel(control_unit_output[`CONTROL_PC_TO_REG]),  // CTRL_UNIT ->
      .mux_out(register_write_data)  // -> REG_FILE.RD_DIN
  );

  mux32bit mux_alu_in_2_select (
      .mux_in_0(reg_file_read_dout2),  // REG_FILE.RS2_DOUT -> 
      .mux_in_1(mux_alu_in_2_mux_in_1),  // IMM_GEN.IMM_GEN_OUT -> 
      .sel(control_unit_output[`CONTROL_ALU_SRC]),  // CTRL_UNIT -> 
      .mux_out(alu_in2_input)  // -> ALU.ALU_IN_2
  );

  mux32bit mux_dmem_out_select (
      .mux_in_0(alu_output),  // ALU.ALU_RESULT -> 
      .mux_in_1(dmem_output),  // DMEM.DOUT -> 
      .sel(control_unit_output[`CONTROL_MEM_TO_REG]),  // CTRL_UNIT ->
      .mux_out(mux_dmem_output)  // -> MUX_REGISTER_WRITE_DATA_SELECT.MUX_IN_0
  );

  mux32bit mux_alu_in_2_mux_in_1_imm_determine (
      .mux_in_0(imm_gen_output_type_i),  // (@ I-Imm, Load, JALR) IMM_GEN.I_IMM -> 
      .mux_in_1(imm_gen_output_type_s),  // (@ Store) IMM_GEN.S_IMM -> 
      .sel(control_unit_output[`CONTROL_MEM_WRITE]),  // CTRL_UNIT -> 
      .mux_out(mux_alu_in_2_mux_in_1)  // -> MUX_ALU_IN_2_SELECT.MUX_IN_1
  );

  adder32bit adder_adjacent_pc_address (
      .adder_in_0(current_pc_address),  // PC.CURRENT_PC ->
      .adder_in_1(32'h00000004),
      .adder_out(adjacent_pc_address) // -> MUX_BRANCH_SELECT.MUX_IN_0, -> MUX_REGISTER_FILE_SELECT
  );

  mux32bit adder_offset_pc_address_adder_in_1_determine (
      .mux_in_0(imm_gen_output_type_b),  // (@ Branch) IMM_GEN.B_IMM ->
      .mux_in_1(imm_gen_output_type_j),  // (@ JAL) IMM_GEN.J_IMM ->
      .sel(control_unit_output[`CONTROL_JAL]),  // CTRL_UNIT -> 
      .mux_out(adder_offset_pc_address_adder_in_1)  // -> ADDER_OFFSET_PC_ADDRESS.ADDER_IN_1
  );

  adder32bit adder_offset_pc_address (
      .adder_in_0(current_pc_address),  // PC.CURRENT_PC -> 
      .adder_in_1(adder_offset_pc_address_adder_in_1), // ADDER_OFFSET_PC_ADDRESS_ADDER_IN_1_DETERMINE.MUX_OUT
      .adder_out(added_offset_pc_address)  // -> MUX_BRANCH_SELECT.MUX_IN_1
  );

  mux32bit mux_branch_select (
      .mux_in_0(adjacent_pc_address),  // ADDER_ADJACENT_PC_ADDRESS.ADDER_OUT ->
      .mux_in_1(added_offset_pc_address),  // ADDER_OFFSET_PC_ADDRESS.ADDER_OUT ->
      .sel(control_unit_output[`CONTROL_JAL] | (control_unit_output[`CONTROL_BRANCH] & alu_output[0])), // CTRL_UNIT -> , CTRL_UNIT ->, ALU.ALU_RESULT[0]
      .mux_out(branch_determined_pc_address)  // -> MUX_ALU_ADDRESS_SELECT.MUX_IN_0
  );

  mux32bit mux_alu_address_select (
      .mux_in_0(branch_determined_pc_address),  // MUX_BRANCH_SELECT.MUX_OUT -> 
      .mux_in_1(alu_output),  // ALU.ALU_RESULT ->
      .sel(control_unit_output[`CONTROL_JALR]),  // CTRL_UNIT ->
      .mux_out(next_pc_address)  // -> PC.NEXT_PC
  );
endmodule
