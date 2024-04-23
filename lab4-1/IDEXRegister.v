module IDEXRegister (
    input clk,
    input reset,

    input wb_enable_in,
    input mem_enable_in,
    input mem_write_in,
    input op2_imm_in,
    input is_ecall_in,

    input [31:0] rs1_in,
    input [31:0] rs2_in,
    input [ 4:0] rd_id_in,

    output reg wb_enable,
    output reg mem_enable,
    output reg mem_write,
    output reg op2_imm,
    output reg is_ecall,

    output reg [31:0] rs1,
    output reg [31:0] rs2,
    output reg [ 4:0] rd_id
);
  always @(posedge clk) begin
    if (reset) begin
      wb_enable <= 0;
      mem_enable <= 0;
      mem_write <= 0;
      op2_imm <= 0;
      is_ecall <= 0;

      rs1 <= 32'b0;
      rs2 <= 32'b0;
      rd_id <= 5'b0;
    end else begin
      wb_enable <= wb_enable_in;
      mem_enable <= mem_enable_in;
      mem_write <= mem_write_in;
      op2_imm <= op2_imm_in;
      is_ecall <= is_ecall_in;

      rs1 <= rs1_in;
      rs2 <= rs2_in;
      rd_id <= rd_id_in;
    end
  end
endmodule