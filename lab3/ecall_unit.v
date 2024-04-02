module ecall_unit (
    input enable,
    input [11:0] func12,
    input [31:0] x17_value,

    output is_halted
);
  assign is_halted = enable && func12 == 12'b0 && x17_value == 32'd10;
endmodule
