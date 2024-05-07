module ControlHazardDetectionUnit (
    input [31:0] resolved_pc,
    input [31:0] predicted_pc,

    output is_hazardous
);
  assign is_hazardous = resolved_pc != predicted_pc;
endmodule
