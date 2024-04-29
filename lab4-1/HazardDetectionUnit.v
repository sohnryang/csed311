module HazardDetectionUnit (
    // ----- ALU Input Register: To Be Compared -----
    input enable,
    input [4:0] rs_id,

    input ex_mem_read,
    input [4:0] ex_rd_id,

    // ----- Output -----
    output reg is_hazardous  // Is instruction hazardous?
);
  always @(*) begin
    if (enable && rs_id != 5'b0) begin
      is_hazardous = (rs_id == ex_rd_id) && ex_mem_read;
    end else begin
      is_hazardous = 0;
    end
  end
endmodule
