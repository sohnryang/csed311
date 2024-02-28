`include "alu_func.v"

module alu #(parameter data_width = 16) (
	input [data_width - 1 : 0] A, 
	input [data_width - 1 : 0] B, 
	input [3 : 0] FuncCode,
       	output reg [data_width - 1: 0] C,
       	output reg OverflowFlag);
// Do not use delay in your implementation.

// You can declare any variables as needed.
/*
	YOUR VARIABLE DECLARATION...
*/

initial begin
	C = 0;
	OverflowFlag = 0;
end   	

// TODO: You should implement the functionality of ALU!
// (HINT: Use 'always @(...) begin ... end')
/*
	YOUR ALU FUNCTIONALITY IMPLEMENTATION...
*/
	always begin
		case (FuncCode)
			`FUNC_ADD: begin
				assign C = A + B;
				assign OverflowFlag = ~(A[data_width - 1] ^ B[data_width - 1]) & (A[data_width - 1] ^ C[data_width - 1]);
			end
			`FUNC_SUB: begin
				assign C = A - B;
				assign OverflowFlag = (A[data_width - 1] ^ B[data_width - 1]) & (A[data_width - 1] ^ C[data_width - 1]);
			end
			`FUNC_ID: begin
				assign C = A;
				assign OverflowFlag = 1'b0;
			end
			`FUNC_NOT: begin
				assign C = ~A;
				assign OverflowFlag = 1'b0;
			end
			`FUNC_AND: begin
				assign C = A & B;
				assign OverflowFlag = 1'b0;
			end
			`FUNC_OR: begin
				assign C = A | B;
				assign OverflowFlag = 1'b0;
			end
			`FUNC_NAND: begin
				assign C = ~(A & B);
				assign OverflowFlag = 1'b0;
			end
			`FUNC_NOR: begin
				assign C = ~(A | B);
				assign OverflowFlag = 1'b0;
			end
			`FUNC_XOR: begin
				assign C = A ^ B;
				assign OverflowFlag = 1'b0;
			end
			`FUNC_XNOR: begin
				assign C = ~(A ^ B);
				assign OverflowFlag = 1'b0;
			end
			`FUNC_LLS: begin
				assign C = A << 1;
				assign OverflowFlag = 1'b0;
			end
			`FUNC_LRS: begin
				assign C = A >> 1;
				assign OverflowFlag = 1'b0;
			end
			`FUNC_ALS: begin
				assign C = signed'(A) <<< 1;
				assign OverflowFlag = 1'b0;
			end
			`FUNC_ARS: begin
				assign C = signed'(A) >>> 1;
				assign OverflowFlag = 1'b0;
			end
			`FUNC_TCP: begin
				assign C = ~A + 1;
				assign OverflowFlag = 1'b0;
			end
			`FUNC_ZERO: begin
				assign C = 16'b0000_0000_0000_0000;
				assign OverflowFlag = 1'b0;
			end
		endcase
	end

endmodule

