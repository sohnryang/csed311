module mux32bit_2x1 (
    input [31:0] mux_in_0,
    input [31:0] mux_in_1,
    input sel,

    output reg [31:0] mux_out
);
  always @(*) begin
    case (sel) begin
      1'b0: mux_out = mux_in_0;
      1'b1: mux_out = mux_in_1;
    endcase
  end
endmodule

module mux32bit_4x1(
  input [31:0] mux_in_0,
  input [31:0] mux_in_1,
  input [31:0] mux_in_2,
  input [31:0] mux_in_3,
  input [1:0] sel,

  output reg [31:0] mux_out
);
  always @(*) begin
    case (sel) begin
      2'b00: mux_out = mux_in_0;
      2'b01: mux_out = mux_in_1;
      2'b10: mux_out = mux_in_2;
      2'b11: mux_out = mux_in_3;
    endcase
  end
endmodule
