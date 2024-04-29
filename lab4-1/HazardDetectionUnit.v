module HazardDetectionUnit (
    // ----- ALU Input Register: To Be Compared -----
    input enable,
    input [4:0] rs_id,

    // ----- Distance 1 Hazard Detection: From EX/MEM Stage -----
    input ex_reg_write,
    input [4:0] ex_rd_id,

    // ----- Distance 2 Hazard Detection: From MEM/WB Stage -----
    input mem_reg_write,
    input [4:0] mem_rd_id,

    // ----- Output -----
    output reg is_hazardous  // Is instruction hazardous?
);
  always @(*) begin
    if (enable && rs_id != 5'b0) begin
      is_hazardous = ((rs_id == ex_rd_id) && ex_reg_write) || ((rs_id==mem_rd_id) && mem_reg_write);
    end else begin
      is_hazardous = 0;
    end
  end
endmodule
