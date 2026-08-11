//forwarding_unit.v
module forwarding_unit(
    input [4:0] id_ex_rs1,
    input [4:0] id_ex_rs2,

    input [4:0] ex_mem_rd,
    input ex_mem_reg_write,

    input [4:0] mem_wb_rd,
    input mem_wb_reg_write,

    output reg [1:0] forward_a,
    output reg [1:0] forward_b
);

    always @(*) begin
        if (ex_mem_reg_write && (ex_mem_rd != 5'b0) && (ex_mem_rd == id_ex_rs1))
            forward_a = 2'b10;
        else if (mem_wb_reg_write && (mem_wb_rd != 5'b0) && (mem_wb_rd == id_ex_rs1))
            forward_a = 2'b01;
        else
            forward_a = 2'b00;

        if (ex_mem_reg_write && (ex_mem_rd != 5'b0) && (ex_mem_rd == id_ex_rs2))
            forward_b = 2'b10;
        else if (mem_wb_reg_write && (mem_wb_rd != 5'b0) && (mem_wb_rd == id_ex_rs2))
            forward_b = 2'b01;
        else
            forward_b = 2'b00;
    end
    
wire [31:0] forward_mux_a, forward_mux_b;
    always @(*) begin
        case(forward_a)
        2'b10: forward_mux_a = mem_alu_result;
        2'b01: forward_mux_a = wb_write_back_data;
        default: forward_mux_a = ex_read_data1;
        endcase
    end

    always @(*) begin
        case(forward_b)
        2'b10: forward_mux_b = mem_alu_result;
        2'b01: forward_mux_b = wb_write_back_data;
        default: forward_mux_b = ex_read_data2;
        endcase
    end
endmodule