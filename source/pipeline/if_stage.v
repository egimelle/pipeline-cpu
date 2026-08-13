module if_stage(
    input clk,
    input rst,
    input pc_write,
    input [31:0] pc_next,

    output [31:0] pc_out,
    output [31:0] instruction,
    output [31:0] pc_plus4
);

    pc pc_inst(
        .clk(clk),
        .rst(rst),
        .pc_write(pc_write),
        .pc_next(pc_next),
        .pc_out(pc_out)
    );
    instruction_memory instruction_memory_inst(
        .addr(pc_out),
        .instruction(instruction)
    );
    assign pc_plus4 = pc_out + 32'd4;
endmodule
