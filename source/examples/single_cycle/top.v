module top(
    input clk,
    input rst
);

//pc 
wire [31:0] pc_out;
wire [31:0] pc_plus4;
wire [31:0] pc_branch;
wire [31:0] pc_next;
pc pc_inst(
    .clk(clk),
    .rst(rst),
    .pc_next(pc_next),
    .pc_out(pc_out)
);
//next pc
assign pc_plus4 = pc_out + 32'd4;
assign pc_branch = pc_out + imm_out;
assign pc_next = (branch && zero) ? pc_branch : pc_plus4;

//instruction memory
wire [31:0] instruction;
instruction_memory instruction_memory_inst(
    .addr(pc_out),
    .instruction(instruction)
);

//control unit
wire reg_write, alu_src, mem_write, mem_to_reg, branch, mem_read;
wire [1:0] alu_op;
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

//immediate generator
wire [31:0] imm_out;
imm_gen imm_gen_inst(
    .instruction(instruction),
    .imm_out(imm_out)
);

//register file
wire [31:0] read_data1, read_data2;
wire [31:0] write_back_data;
register_file register_file_inst(
    .clk(clk),
    .reg_write(reg_write),
    .rs1(instruction[19:15]),
    .rs2(instruction[24:20]),
    .rd(instruction[11:7]),
    .write_data(write_back_data),
    .read_data1(read_data1),
    .read_data2(read_data2)
);

//alu_control
wire [3:0] alu_control_signal;
alu_control alu_control_inst(
    .alu_op(alu_op),
    .funct3(instruction[14:12]),
    .funct7(instruction[30]),
    .is_rtype(instruction[5]),
    .alu_control(alu_control_signal)
);

//alu input mux
wire [31:0] alu_b;
assign alu_b = alu_src ? imm_out : read_data2;

//alu
wire [31:0] alu_result;
wire zero;
alu alu_inst(
    .a(read_data1),
    .b(alu_b),
    .alu_control(alu_control_signal),
    .result(alu_result),
    .zero(zero)
);

//data memory
wire [31:0] mem_read_data;
data_memory data_memory_inst(
    .clk(clk),
    .mem_read(mem_read),
    .mem_write(mem_write),
    .addr(alu_result),
    .write_data(read_data2),
    .read_data(mem_read_data)
);

// write_back mux
assign write_back_data = mem_to_reg ? mem_read_data : alu_result;

endmodule