module mux32bit_2x1 (
    input [31:0] mux_in_0,
    input [31:0] mux_in_1,
    input sel,

    output reg [31:0] mux_out
);
  always @(*) begin
    case (sel)
      1'b0: mux_out = mux_in_0;
      1'b1: mux_out = mux_in_1;
    endcase
  end
endmodule
