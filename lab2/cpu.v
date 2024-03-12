// Submit this file with other files you created.
// Do not touch port declarations of the module 'cpu'.

// Guidelines
// 1. It is highly recommened to `define opcodes and something useful.
// 2. You can modify the module.
// (e.g., port declarations, remove modules, define new modules, ...)
// 3. You might need to describe combinational logics to drive them into the module (e.g., mux, and, or, ...)
// 4. `include files if required
`include "cpu_def.v"

module cpu(input reset,                     // positive reset signal
           input clk,                       // clock signal
           output is_halted,                // Whehther to finish simulation
           output [31:0] print_reg [0:31]); // TO PRINT REGISTER VALUES IN TESTBENCH (YOU SHOULD NOT USE THIS)
  /***** Wire declarations *****/

  wire [31:0] instruction;
  wire [31:0] alu_operation;

  wire [31:0] reg_file_read_dout1;
  wire [31:0] reg_file_read_dout2;

  wire [31:0] register_write_data;
  wire [31:0] alu_in2_input;

  wire [31:0] alu_output;

  wire [31:0] imm_gen_ouput;

  wire [31:0] dmem_output;

  wire [31:0] mux_dmem_output;

  wire alu_bcond_output;

  wire control_unit_output [0:`CONTROL_UNIT_LINES_COUNT - 1];

  /***** Register declarations *****/

  // ---------- Update program counter ----------
  // PC must be updated on the rising edge (positive edge) of the clock.
  pc pc(
    .reset(),       // input (Use reset to initialize PC. Initial value must be 0)
    .clk(),         // input
    .next_pc(),     // input
    .current_pc()   // output
  );
  
  // ---------- Instruction Memory ----------
  instruction_memory imem(
    .reset(),   // input
    .clk(),     // input
    .addr(),    // input
    .dout(instruction)     // output
  );

  // ---------- Register File ----------
  register_file reg_file (
    .reset (),        // input
    .clk (),          // input
    .rs1 (instruction[19:15]),          // input
    .rs2 (instruction[24:20]),          // input
    .rd (instruction[11:7]),           // input
    .rd_din (register_write_data_out),       // input
    .write_enable (control_unit_output[`CONTROL_REG_WRITE]), // input
    .rs1_dout (reg_file_read_dout1),     // output
    .rs2_dout (reg_file_read_dout2),     // output
    .print_reg (print_reg)  //DO NOT TOUCH THIS
  );


  // ---------- Control Unit ----------
  control_unit ctrl_unit (
    .part_of_inst(instruction[6:0]),  // input
    .is_jal(control_unit_output[`CONTROL_JAL]),        // output
    .is_jalr(control_unit_output[`CONTROL_JALR]),       // output
    .branch(control_unit_output[`CONTROL_BRANCH]),        // output
    .mem_read(control_unit_output[`CONTROL_MEM_READ]),      // output
    .mem_to_reg(control_unit_output[`CONTROL_MEM_TO_REG]),    // output
    .mem_write(control_unit_output[`CONTROL_MEM_WRITE]),     // output
    .alu_src(control_unit_output[`CONTROL_ALU_SRC]),       // output
    .write_enable(control_unit_output[`CONTROL_REG_WRITE]),  // output
    .pc_to_reg(control_unit_output[`CONTROL_PC_TO_REG]),     // output
    .is_ecall(control_unit_output[`CONTROL_IS_ECALL])       // output (ecall inst)
  );

  // ---------- Immediate Generator ----------
  immediate_generator imm_gen(
    .part_of_inst(instruction),  // input
    .imm_gen_out(imm_gen_ouput)    // output
  );

  // ---------- ALU Control Unit ----------
  alu_control_unit alu_ctrl_unit (
    .part_of_inst({inst[30], instruction[14:12], instruction[6:0]}),  // input
    .alu_op(alu_operation)         // output
  );

  // ---------- ALU ----------
  alu alu (
    .alu_op(alu_operation),      // input
    .alu_in_1(reg_file_read_dout1),    // input  
    .alu_in_2(alu_in2_input),    // input
    .alu_result(alu_output),  // output
    .alu_bcond(alu_bcond_output)    // output
  );

  // ---------- Data Memory ----------
  data_memory dmem(
    .reset (),      // input
    .clk (),        // input
    .addr (alu_result),       // input
    .din (reg_file_read_dout2),        // input
    .mem_read (control_unit_output[`CONTROL_MEM_READ]),   // input
    .mem_write (control_unit_output[`CONTROL_MEM_WRITE]),  // input
    .dout (dmem_output)        // output
  );

  mux32bit mux_register_write_data_select(
    .mux_in_0(mux_dmem_output),  // Data memeory out
    .mux_in_1(),  // PC + 4
    .sel(control_unit_output[`CONTROL_PC_TO_REG]),
    .mux_out(register_write_data)  // to reg_file.rd_din
  );

  mux32bit mux_alu_in_2_select(
    .mux_in_0(reg_file_read_dout2),  // reg_file.rs2_dout
    .mux_in_1(imm_gen_ouput),  // imm_gen.imm_gen_out
    .sel(control_unit_output[`CONTROL_ALU_SRC]),
    .mux_out(alu_in2_input)  // to alu.alu_in_2
  );

  mux32bit mux_dmem_out_select(
    .mux_in_0(alu_result),
    .mux_in_1(dmem_output),
    .sel(control_unit_output[`CONTROL_MEM_TO_REG]),
    .mux_out(mux_dmem_output)
  )


endmodule
