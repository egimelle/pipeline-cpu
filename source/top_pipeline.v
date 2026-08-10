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

id_stage id_stage_inst(
    .clk(clk),
    .instruction(id_instruction),
    .write_data_wb(32'b0), 
    .reg_write_wb(1'b0), 
    .rd_wb(5'b0), 
    
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

endmodule