module EcallUnit (
    input is_ecall,
    input x17_data,

    output is_halted
);
  assign is_halted = is_ecall && (x17_data == 32'ha);
endmodule
