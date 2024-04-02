// Submit this file with other files you created.
// Do not touch port declarations of the module 'CPU'.
`include 
// Guidelines
// 1. It is highly recommened to `define opcodes and something useful.
// 2. You can modify the module.
// (e.g., port declarations, remove modules, define new modules, ...)
// 3. You might need to describe combinational logics to drive them into the module (e.g., mux, and, or, ...)
// 4. `include files if required

module cpu (
    input         reset,           // positive reset signal
    input         clk,             // clock signal
    output        is_halted,
    output [31:0] print_reg[0:31]
);  // Whehther to finish simulation
  /***** Wire declarations *****/

  /***** Register declarations *****/
  reg [31:0] IR;  // instruction register
  reg [31:0] MDR;  // memory data register
  reg [31:0] A;  // Read 1 data register
  reg [31:0] B;  // Read 2 data register
  reg [31:0] ALUOut;  // ALU output register
  // Do not modify and use registers declared above.

  // ---------- Update program counter ----------
  wire [31:0] pc_current_pc;
  // PC must be updated on the rising edge (positive edge) of the clock.
  PC pc (
      .reset     (reset),           // input (Use reset to initialize PC. Initial value must be 0)
      .clk       (clk),             // input
      .next_pc   (),                // input
      .current_pc(pc_current_pc)    // output
  );

  // ---------- Register File ----------
  RegisterFile reg_file (
      .reset       (reset),                             // input
      .clk         (clk),                               // input
      .rs1         (IR[19:15]),                         // IR[19:15] ->
      .rs2         (IR[24:20]),                         // IR[24:20] ->
      .rd          (IR[11:7]),                          // IR[11:7] ->
      .rd_din      (reg_file_write_data_mux_mux_out),   // reg_file_write_data_mux.mux_out
      .write_enable(ctrl_unit_reg_write),               // ctrl_unit.reg_write -> 
      .rs1_dout    (A),                                 // -> A
      .rs2_dout    (B),                                 // -> B
      .print_reg   ()                                   // output (TO PRINT REGISTER VALUES IN TESTBENCH)
  );

  wire [31:0] reg_file_write_data_mux_mux_out;
  mux32bit_2x1 reg_file_write_data_mux(
    .mux_in_0(ALUOut),                          // ALUOut ->
    .mux_in_1(MDR),                             // MDR ->
    .sel(ctrl_unit_mem_to_reg),                 // ctrl_unit.mem_to_reg
    .mux_out(reg_file_write_data_mux_mux_out)   // reg_file.rd_din
  )

  // ---------- Memory ----------
  wire[31:0] memory_dout;
  Memory memory (
      .reset    (reset),                    // input
      .clk      (clk),                      // input
      .addr     (memory_addr_mux_mux_out),  // memory_addr_mux.mux_out -> 
      .din      (B),                        // B -> 
      .mem_read (ctrl_unit_mem_read),       // ctrl_unit.mem_read ->
      .mem_write(ctrl_unit_mem_write),      // ctrl_unit.mem_write -> 
      .dout     (memory_dout)               // -> inst_reg / -> mem_data_reg
  );
  
  wire [31:0] memory_addr_mux_mux_out;
  mux32bit_2x1 memory_addr_mux(
    .mux_in_0(pc_current_pc),               // pc.current_pc -> 
    .mux_in_1(ALUOut),                      // ALUOut ->
    .sel(ctrl_unit_data_read),              // ctrl_unit.data_read ->
    .mux_out(memory_addr_mux_mux_out)       // -> memory.addr
  )

  // ---------- Control Unit ----------
  wire ctrl_unit_is_branch;
  wire ctrl_unit_reg_write;
  wire ctrl_unit_op1_regfile;
  wire [1:0] ctrl_unit_op2_sel;
  wire [3:0] ctrl_unit_alu_op;
  wire ctrl_unit_pc_source;
  wire ctrl_unit_pc_write_not_cond;
  wire ctrl_unit_pc_write;
  wire ctrl_unit_data_read;
  wire ctrl_unit_mem_read;
  wire ctrl_unit_mem_write;
  wire ctrl_unit_mem_to_reg;
  wire ctrl_unit_inst_reg_write;
  wire ctrl_unit_is_ecall;

  ControlUnit ctrl_unit (
      .part_of_inst(IR[6:0]),               // -> IR[6:0]
      .reg_write(ctrl_unit_reg_write),
      .op1_regfile(ctrl_unit_op1_regfile),
      .op2_sel(ctrl_unit_op2_sel),
      .alu_op(ctrl_unit_alu_op),
      .pc_source(ctrl_unit_pc_source),
      .pc_write_not_cond(ctrl_unit_pc_write_not_cond),
      .pc_write(ctrl_unit_pc_write),
      .data_read(ctrl_unit_data_read),
      .mem_read(ctrl_unit_mem_read),
      .mem_write(ctrl_unit_mem_write),
      .mem_to_reg(ctrl_unit_mem_to_reg),
      .inst_reg_write(ctrl_unit_inst_reg_write),
      .is_ecall(ctrl_unit_is_ecall)   // output (ecall inst)
  );

  // ---------- Immediate Generator ----------
  wire [31:0] imm_gen_imm_gen_out;
  ImmediateGenerator imm_gen (
      .part_of_inst(IR),                    // IR[31:0] ->
      .imm_gen_out (imm_gen_imm_gen_out)    // -> alu_in_2_mux.mux_in_2
  );

  // ---------- ALU Control Unit ----------
  wire [31:0] alu_ctrl_unit_alu_op;
  ALUControlUnit alu_ctrl_unit (
      .part_of_inst({IR[30], IR[14:12]}),   // IR[30,14-12] -> 
      .alu_op      (alu_ctrl_unit_alu_op)   // -> alu_ctrl_unit.alu_op
  );

  // ---------- ALU ----------
  wire [31:0] alu_alu_result;
  ALU alu (
      .alu_op    (alu_ctrl_unit_alu_op),  // input
      .alu_in_1  (alu_in_1_mux_mux_out),  // input  
      .alu_in_2  (alu_in_2_mux_mux_out),  // input
      .alu_result(alu_alu_result),  // output
      .alu_bcond (alu_alu_result[0])   // output
  );

  // ----- ALU INPUT MUX -----
  wire [31:0] alu_in_1_mux_mux_out;

  mux32bit_2x1 alu_in_1_mux(
    .mux_in_0(pc_current_pc),           // pc.current_pc -> 
    .mux_in_1(A),                       // A ->
    .sel(ctrl_unit_op1_regfile),        // ctrl_unit.op1_regfile ->
    .mux_out(alu_in_1_mux_mux_out)      // -> alu.alu_in_1
  );

  wire [31:0] alu_in_2_mux_mux_out;

    mux32bit_4x1 alu_in_2_mux (
    .mux_in_0(B),                       // B -> 
    .mux_in_1(32'h00000004),            // 32'h4 ->
    .mux_in_2(imm_gen_imm_gen_out),     // imm_gen.imm_gen_out ->
    .mux_in_3(32'h00000000),            // [NOT USED]
    .sel(ctrl_unit_op2_sel),            // ctrl_unit.op2_sel -> 
    .mux_out(alu_in_2_mux_mux_out)      // -> alu.alu_in_2
  );

endmodule
