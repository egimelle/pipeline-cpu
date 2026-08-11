module top_pipeline(
    input clk,
    input rst
);

//IF
wire [31:0] if_pc_out, if_instruction, if_pc_plus4;
if_stage if_stage_inst(
    .clk(clk),
    .rst(rst),
    .pc_next(if_pc_plus4),
    .pc_out(if_pc_out),
    .instruction(if_instruction),
    .pc_plus4(if_pc_plus4)
);

//IF/ID
wire [31:0] id_pc, id_instruction;
if_id if_id_inst(
    .clk(clk),
    .rst(rst),
    .pc_in(if_pc_out),
    .instruction_in(if_instruction),
    .pc_out(id_pc),
    .instruction_out(id_instruction)
);

//ID
wire reg_write, alu_src, mem_write, mem_to_reg, branch, mem_read;
wire [1:0] alu_op;
wire [31:0] read_data1, read_data2, imm_out;
wire [4:0] rs1, rs2, rd;
wire [2:0] funct3;
wire funct7;
wire is_rtype;
wire [31:0] wb_read_data_mem, wb_alu_result;
wire [4:0] wb_rd;
wire wb_reg_write, wb_mem_to_reg;
wire [31:0] wb_write_back_data;

id_stage id_stage_inst(
    .clk(clk),
    .instruction(id_instruction),
    .write_data_wb(wb_write_back_data), 
    .reg_write_wb(wb_reg_write), 
    .rd_wb(wb_rd), 

    .reg_write(reg_write),
    .alu_src(alu_src),
    .mem_write(mem_write),
    .mem_to_reg(mem_to_reg),
    .branch(branch),
    .mem_read(mem_read),
    .alu_op(alu_op),

    .read_data1(read_data1),
    .read_data2(read_data2),
    .imm_out(imm_out),

    .rs1(rs1),
    .rs2(rs2),
    .rd(rd),
    .funct3(funct3),
    .funct7(funct7),
    .is_rtype(is_rtype)
);

//ID/EX
wire [31:0] ex_pc, ex_read_data1, ex_read_data2, ex_imm_out;
wire [4:0] ex_rs1, ex_rs2, ex_rd;
wire [1:0] ex_alu_op;
wire ex_alu_src, ex_reg_write, ex_mem_write, ex_mem_to_reg, ex_mem_read, ex_branch;
wire [2:0] ex_funct3;
wire ex_funct7, ex_is_rtype;

id_ex id_ex_inst(
    .clk(clk),
    .rst(rst),

    .pc_in(id_pc),
    .read_data1_in(read_data1),
    .read_data2_in(read_data2),
    .imm_out_in(imm_out),

    .rs1_in(rs1),
    .rs2_in(rs2),
    .rd_in(rd),

    .alu_op_in(alu_op),
    .alu_src_in(alu_src),
    .reg_write_in(reg_write),
    .mem_write_in(mem_write),
    .mem_to_reg_in(mem_to_reg),
    .mem_read_in(mem_read),
    .branch_in(branch),

    .funct3_in(funct3),
    .funct7_in(funct7),
    .is_rtype_in(is_rtype),

    .pc_out(ex_pc),
    .read_data1_out(ex_read_data1),
    .read_data2_out(ex_read_data2),
    .imm_out(ex_imm_out),
    .rs1_out(ex_rs1),
    .rs2_out(ex_rs2),
    .rd_out(ex_rd),
    .alu_op_out(ex_alu_op),
    .alu_src_out(ex_alu_src),
    .reg_write_out(ex_reg_write),
    .mem_write_out(ex_mem_write),
    .mem_to_reg_out(ex_mem_to_reg),
    .mem_read_out(ex_mem_read),
    .branch_out(ex_branch),
    .funct3_out(ex_funct3),
    .funct7_out(ex_funct7),
    .is_rtype_out(ex_is_rtype)
);

//EX
wire [31:0] ex_alu_result, ex_branch_target;
wire ex_zero;
ex_stage ex_stage_inst(
    .pc(ex_pc),
    .read_data1(ex_read_data1),
    .read_data2(ex_read_data2),
    .imm_out(ex_imm_out),
    .alu_op(ex_alu_op),
    .alu_src(ex_alu_src),
    .funct3(ex_funct3),
    .funct7(ex_funct7),
    .is_rtype(ex_is_rtype),

    .alu_result(ex_alu_result),
    .zero(ex_zero),
    .branch_target(ex_branch_target)
);

//EX/MEM
wire [31:0] mem_alu_result, mem_write_data;
wire [4:0] mem_rd;
wire mem_reg_write, mem_mem_write, mem_mem_to_reg, mem_mem_read;
ex_mem ex_mem_inst(
    .clk(clk),
    .rst(rst),

    .alu_result_in(ex_alu_result),
    .write_data_in(ex_read_data2),
    .rd_in(ex_rd),
    .reg_write_in(ex_reg_write),
    .mem_write_in(ex_mem_write),
    .mem_to_reg_in(ex_mem_to_reg),
    .mem_read_in(ex_mem_read),

    .alu_result_out(mem_alu_result),
    .write_data_out(mem_write_data),
    .rd_out(mem_rd),
    .reg_write_out(mem_reg_write),
    .mem_write_out(mem_mem_write),
    .mem_to_reg_out(mem_mem_to_reg),
    .mem_read_out(mem_mem_read)
);

//MEM
wire [31:0] mem_read_data;
mem_stage mem_stage_inst(
    .clk(clk),
    .mem_read(mem_mem_read),
    .mem_write(mem_mem_write),
    .alu_result(mem_alu_result),
    .read_data2(mem_write_data),
    .mem_read_data(mem_read_data)
);

//MEM/WB
mem_wb mem_wb_inst(
    .clk(clk),
    .rst(rst),
    .read_data_mem_in(mem_read_data),
    .alu_result_in(mem_alu_result),
    .rd_in(mem_rd),
    .reg_write_in(mem_reg_write),
    .mem_to_reg_in(mem_mem_to_reg),

    .read_data_mem_out(wb_read_data_mem),
    .alu_result_out(wb_alu_result),
    .rd_out(wb_rd),
    .reg_write_out(wb_reg_write),
    .mem_to_reg_out(wb_mem_to_reg)
);


//WB
wb_stage wb_stage_inst(
    .mem_to_reg(wb_mem_to_reg),
    .mem_read_data(wb_read_data_mem),
    .alu_result(wb_alu_result),

    .write_back_data(wb_write_back_data)
);

endmodule