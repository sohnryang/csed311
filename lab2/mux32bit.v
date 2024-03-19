module mux32bit (
    input [31:0] mux_in_0,
    input [31:0] mux_in_1,
    input sel,

    output reg [31:0] mux_out
);
  always @(*) begin
    if (sel) mux_out = mux_in_0;
    else mux_out = mux_in_1;
  end
endmodule
