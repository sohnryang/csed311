module HazardDetectionUnit(
    input clk,
    input reset,

    // ----- ALU Input Register: To Be Compared -----
    input [4:0] id_ex_rs;

    // ----- Distance 1 Hazard Detection: From EX/MEM Stage -----
    input [4:0] ex_mem_rd;
    input [31:0] ex_mem_reg_write;
    input [31:0] ex_mem_alu_out;

    // ----- Distance 2 Hazard Detection: From MEM/WB Stage -----
    input [4:0] mem_wb_rd;
    input [31:0] mem_wb_reg_write;
    input [31:0] mem_wb_mem_to_reg;

    // ----- Output -----
    output reg [31:0] value;    // Value to be forwarded
    output reg is_harzardous;   // Is instruction hazardous?
);
    always @(posedge clk) begin
        if ((id_ex_rs == ex_mem_rd) && (id_ex_rs != 5'b00000) && ex_mem_reg_write == 1'b1) begin    // Distance 1 Hazard condition
            is_harzardous <= 1'b1;      
            value <= ex_mem_alu_out;    // Forward EX/MEM stage ALU output to ALU operand
        end else if ((id_ex_rs == mem_wb_rd) && (id_ex_rs != 5'b00000) && mem_wb_reg_write == 1'b1) begin   // Distance 2 Hazard condition
            is_hazardous <= 1'b1;
            value <= mem_wb_mem_to_reg; // Forward MEM/WB stage Memory contents to ALU operand
        end else begin
            is_hazardous <= 1'b0;
            value <= 32'h00000000;
        end
        if (reset) begin
            is_hazardous <= 1'b0;
            value <= 32'h00000000;
        end
    end
endmodule