module top_pipeline(
    input clk,
    input rst
);
wire flush;
wire [31:0] if_pc_next;
wire pc_write, if_id_write, control_mux_sel;
wire [31:0] if_pc_out, if_instruction, if_pc_plus4;
if_stage if_stage_inst(
    .clk(clk),
    .rst(rst),
    .pc_write(pc_write),
    .pc_next(if_pc_next),
    .pc_out(if_pc_out),
    .instruction(if_instruction),
    .pc_plus4(if_pc_plus4)
);

wire [31:0] id_pc, id_instruction;
if_id if_id_inst(
    .clk(clk),
    .rst(rst),
    .flush(flush),
    .if_id_write(if_id_write),
    .pc_in(if_pc_out),
    .instruction_in(if_instruction),
    .pc_out(id_pc),
    .instruction_out(id_instruction)
);

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

wire [31:0] ex_pc, ex_read_data1, ex_read_data2, ex_imm_out;
wire [4:0] ex_rs1, ex_rs2, ex_rd;
wire [1:0] ex_alu_op;
wire ex_alu_src, ex_reg_write, ex_mem_write, ex_mem_to_reg, ex_mem_read, ex_branch;
wire [2:0] ex_funct3;
wire ex_funct7, ex_is_rtype;

hazard_detection hazard_detection_inst(
    .id_ex_mem_read(ex_mem_read),
    .id_ex_rd(ex_rd),
    .if_id_rs1(rs1),
    .if_id_rs2(rs2),

    .pc_write(pc_write),
    .if_id_write(if_id_write),
    .control_mux_sel(control_mux_sel)
);

wire mux_reg_write   = control_mux_sel ? 1'b0 : reg_write;
wire mux_mem_write   = control_mux_sel ? 1'b0 : mem_write;
wire mux_mem_to_reg  = control_mux_sel ? 1'b0 : mem_to_reg;
wire mux_mem_read    = control_mux_sel ? 1'b0 : mem_read;
wire mux_branch      = control_mux_sel ? 1'b0 : branch;
wire [1:0] mux_alu_op = control_mux_sel ? 2'b00 : alu_op;

id_ex id_ex_inst(
    .clk(clk),
    .rst(rst),
    .flush(flush),

    .pc_in(id_pc),
    .read_data1_in(read_data1),
    .read_data2_in(read_data2),
    .imm_out_in(imm_out),

    .rs1_in(rs1),
    .rs2_in(rs2),
    .rd_in(rd),

    .alu_op_in(mux_alu_op),
    .alu_src_in(alu_src),
    .reg_write_in(mux_reg_write),
    .mem_write_in(mux_mem_write),
    .mem_to_reg_in(mux_mem_to_reg),
    .mem_read_in(mux_mem_read),
    .branch_in(mux_branch),

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

wire [31:0] mem_alu_result, mem_write_data;
wire [4:0] mem_rd;
wire mem_reg_write, mem_mem_write, mem_mem_to_reg, mem_mem_read;

wire [1:0] forward_a, forward_b;
forwarding_unit forwarding_unit_inst(
    .ex_rs1(ex_rs1),
    .ex_rs2(ex_rs2),

    .mem_rd(mem_rd),
    .mem_reg_write(mem_reg_write),

    .wb_rd(wb_rd),
    .wb_reg_write(wb_reg_write),

    .forward_a(forward_a),
    .forward_b(forward_b)
);

wire [31:0] ex_alu_result, ex_branch_target, ex_store_data;
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

    .forward_a(forward_a),
    .forward_b(forward_b),
    .mem_alu_result_fwd(mem_alu_result),
    .wb_write_back_data(wb_write_back_data),

    .alu_result(ex_alu_result),
    .zero(ex_zero),
    .branch_target(ex_branch_target),
    .store_data(ex_store_data)
);

ex_mem ex_mem_inst(
    .clk(clk),
    .rst(rst),

    .alu_result_in(ex_alu_result),
    .write_data_in(ex_store_data),
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

wire [31:0] mem_read_data;
mem_stage mem_stage_inst(
    .clk(clk),
    .mem_read(mem_mem_read),
    .mem_write(mem_mem_write),
    .alu_result(mem_alu_result),
    .read_data2(mem_write_data),
    .mem_read_data(mem_read_data)
);

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

wb_stage wb_stage_inst(
    .mem_to_reg(wb_mem_to_reg),
    .mem_read_data(wb_read_data_mem),
    .alu_result(wb_alu_result),

    .write_back_data(wb_write_back_data)
);

wire pc_src;
assign pc_src = ex_branch && ex_zero;
assign if_pc_next = pc_src ? ex_branch_target : if_pc_plus4;
assign flush = pc_src;
endmodule
