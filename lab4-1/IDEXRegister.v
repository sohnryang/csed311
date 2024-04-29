module IDEXRegister (
    input clk,
    input reset,

    input wb_enable_in,
    input mem_enable_in,
    input mem_write_in,
    input op2_imm_in,
    input is_halted_in,

    input [31:0] rs1_in,
    input [31:0] rs2_in,
    input [ 4:0] rd_id_in,
    input [31:0] inst_in,
    input [31:0] imm_in,

    output reg wb_enable,
    output reg mem_enable,
    output reg mem_write,
    output reg op2_imm,
    output reg is_halted,

    output reg [31:0] rs1,
    output reg [31:0] rs2,
    output reg [ 4:0] rd_id,
    output reg [31:0] inst,
    output reg [31:0] imm
);
  always @(posedge clk) begin
    if (reset) begin
      wb_enable <= 0;
      mem_enable <= 0;
      mem_write <= 0;
      op2_imm <= 0;
      is_halted <= 0;

      rs1 <= 32'b0;
      rs2 <= 32'b0;
      rd_id <= 5'b0;
      inst <= 32'b0;
      imm <= 32'b0;
    end else begin
      wb_enable <= wb_enable_in;
      mem_enable <= mem_enable_in;
      mem_write <= mem_write_in;
      op2_imm <= op2_imm_in;
      is_halted <= is_halted_in;

      rs1 <= rs1_in;
      rs2 <= rs2_in;
      rd_id <= rd_id_in;
      inst <= inst_in;
      imm <= imm_in;
    end
  end
endmodule
