module MEMWBRegister (
    input clk,
    input reset,

    input wb_enable_in,
    input is_halted_in,

    input [ 4:0] rd_id_in,
    input [31:0] rd_in,

    output reg wb_enable,
    output reg is_halted,

    output reg [ 4:0] rd_id,
    output reg [31:0] rd
);
  always @(posedge clk) begin
    if (reset) begin
      wb_enable <= 0;
      is_halted <= 0;

      rd_id <= 5'b0;
      rd <= 32'b0;
    end else begin
      wb_enable <= wb_enable_in;
      is_halted <= is_halted_in;

      rd_id <= rd_id_in;
      rd <= rd_in;
    end
  end
endmodule
