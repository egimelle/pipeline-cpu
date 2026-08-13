module wb_stage(
    input mem_to_reg,
    input [31:0] mem_read_data,
    input [31:0] alu_result,

    output [31:0] write_back_data
);

    assign write_back_data = mem_to_reg ? mem_read_data : alu_result;
endmodule
