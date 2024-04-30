module Adder #(
    parameter WIDTH = 32
) (
    input [WIDTH-1:0] op1,
    input [WIDTH-1:0] op2,

    output [WIDTH-1:0] result
);
  assign result = op1 + op2;
endmodule
