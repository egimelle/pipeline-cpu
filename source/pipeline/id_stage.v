module id_stage(
    input clk,

    input [31:0] instruction,
    input [31:0] write_data_wb,
    input reg_write_wb,
    input [4:0] rd_wb,

    output reg_write,
    output alu_src,
    output mem_write,
    output mem_to_reg,
    output branch,
    output mem_read,
    output [1:0] alu_op,

    output [31:0] read_data1,
    output [31:0] read_data2,
    output [31:0] imm_out,

    output [4:0] rs1,
    output [4:0] rs2,
    output [4:0] rd,
    output [2:0] funct3,
    output funct7,
    output is_rtype
);

    control_unit control_unit_inst(
        .opcode(instruction[6:0]),
        .reg_write(reg_write),
        .alu_src(alu_src),
        .mem_write(mem_write),
        .mem_to_reg(mem_to_reg),
        .branch(branch),
        .mem_read(mem_read),
        .alu_op(alu_op)
    );

    imm_gen imm_gen_inst(
        .instruction(instruction),
        .imm_out(imm_out)
    );

    register_file register_file_inst(
        .clk(clk),
        .reg_write(reg_write_wb),
        .rs1(instruction[19:15]),
        .rs2(instruction[24:20]),
        .rd(rd_wb),
        .write_data(write_data_wb),
        .read_data1(read_data1),
        .read_data2(read_data2)
    );

    assign rs1 = instruction[19:15];
    assign rs2 = instruction[24:20];
    assign rd = instruction[11:7];
    assign funct3 = instruction[14:12];
    assign funct7 = instruction[30];
    assign is_rtype = instruction[5];
endmodule
