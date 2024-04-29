module MUX4X1 #(
    parameter WIDTH = 32
) (
    input [WIDTH-1:0] mux_in_0,
    input [WIDTH-1:0] mux_in_1,
    input [WIDTH-1:0] mux_in_2,
    input [WIDTH-1:0] mux_in_3,
    input [1:0] sel,

    output reg [WIDTH-1:0] mux_out
);
  always @(*) begin
    $display("%x | %x | %x | %x : %d", mux_in_0, mux_in_1, mux_in_2, mux_in_3, sel);
    case (sel)
      2'b00: mux_out = mux_in_0;
      2'b01: mux_out = mux_in_1;
      2'b10: mux_out = mux_in_2;
      2'b11: mux_out = mux_in_3;
    endcase
  end
endmodule
