module forwarding_unit(
    input [4:0] ex_rs1,
    input [4:0] ex_rs2,

    input [4:0] mem_rd,
    input mem_reg_write,

    input [4:0] wb_rd,
    input wb_reg_write,

    output reg [1:0] forward_a,
    output reg [1:0] forward_b
);
    // forward_x = 2'b00 -> no forwarding, use ID/EX value
    // forward_x = 2'b10 -> forward from EX/MEM (mem_alu_result)
    // forward_x = 2'b01 -> forward from MEM/WB (wb_write_back_data)

    always @(*) begin
        // forward A (rs1)
        if (mem_reg_write && (mem_rd != 5'b0) && (mem_rd == ex_rs1))
            forward_a = 2'b10;
        else if (wb_reg_write && (wb_rd != 5'b0) && (wb_rd == ex_rs1))
            forward_a = 2'b01;
        else
            forward_a = 2'b00;

        // forward B (rs2)
        if (mem_reg_write && (mem_rd != 5'b0) && (mem_rd == ex_rs2))
            forward_b = 2'b10;
        else if (wb_reg_write && (wb_rd != 5'b0) && (wb_rd == ex_rs2))
            forward_b = 2'b01;
        else
            forward_b = 2'b00;
    end
endmodule