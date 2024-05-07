module ControlHazardDetectionUnit (
    input enable,
    input [31:0] resolved_pc,
    input [31:0] predicted_pc,

    output is_hazardous
);
  assign is_hazardous = enable & (resolved_pc != predicted_pc);
endmodule
