module mem_stage(
    input clk,

    input mem_read,
    input mem_write,
    input [31:0] alu_result,
    input [31:0] read_data2,

    output [31:0] mem_read_data
);

    //data memory
    data_memory data_memory_inst(
        .clk(clk),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .addr(alu_result),
        .write_data(read_data2),
        .read_data(mem_read_data)
    );

endmodule