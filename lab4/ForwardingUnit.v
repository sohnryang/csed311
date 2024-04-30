module ForwardingUnit (
    input [4:0] rs_id,
    input ex_forwardable,
    input [4:0] ex_rd_id,
    input [31:0] ex_rd,
    input mem_wb_enable,
    input [4:0] mem_rd_id,
    input [31:0] mem_rd,

    output reg is_forward,
    output reg [31:0] forwarded_value
);
  always @(*) begin
    if (ex_forwardable && rs_id == ex_rd_id) begin
      is_forward = 1;
      forwarded_value = ex_rd;
    end else if (mem_wb_enable && rs_id == mem_rd_id) begin
      is_forward = 1;
      forwarded_value = mem_rd;
    end else begin
      is_forward = 0;
      forwarded_value = 32'b0;
    end
  end
endmodule
