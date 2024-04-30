module EcallHazardDetectionUnit (
    input enable,
    input ex_reg_write,
    input [4:0] ex_rd_id,
    input mem_reg_write,
    input [4:0] mem_rd_id,

    output reg is_hazardous
);
  always @(*) begin
    if (enable)
      is_hazardous = ((ex_rd_id == 5'd17) && ex_reg_write) || ((mem_rd_id == 5'd17) && mem_reg_write);
    else is_hazardous = 0;
  end
endmodule
