module mux32bit(
    input [31:0] mux_in_0,
    input [31:0] mux_in_1,
    input sel,
    output [31:0] mux_out,
);

  always begin
    if (sel == 1'b0) begin
        mux_out = mux_in_0;
    end
    else if (sel == 1'b1) begin
        mux_out = mux_in_1;
    end
  end

endmodule