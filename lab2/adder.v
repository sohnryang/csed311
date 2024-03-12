module adder32bit(
    input [31:0] adder_in_0,
    input [31:0] adder_in_1,
    output [31:0] adder_out
);

  always begin
    adder_out = adder_in_0 + adder_in_1;
  end

endmodule