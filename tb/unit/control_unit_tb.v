`timescale 1ns / 1ps

module control_unit_tb;
reg [6:0] opcode;
wire reg_write;
wire alu_src;
wire mem_write;
wire [1:0] alu_op;
wire mem_to_reg;
wire branch;
wire mem_read;

control_unit control_unit_inst (
    .opcode(opcode),
    .reg_write(reg_write),
    .alu_src(alu_src),
    .mem_write(mem_write),
    .alu_op(alu_op),
    .mem_to_reg(mem_to_reg),
    .branch(branch),
    .mem_read(mem_read)
);

initial begin
    $dumpfile ("control_unit_tb.vcd");
    $dumpvars(0, control_unit_tb);

    // Test R-type instruction
    opcode = 7'b0110011; // R-type
    #1;
    $display("add: reg_write=%b, alu_src=%b, mem_write=%b, alu_op=%b, mem_to_reg=%b, branch=%b, mem_read=%b", 
        reg_write, alu_src, mem_write, alu_op, mem_to_reg, branch, mem_read);

    // Test I-type instruction (arithmetic)
    opcode = 7'b0010011; // I-type (arithmetic)
    #1;
    $display("addi: reg_write=%b, alu_src=%b, mem_write=%b, alu_op=%b, mem_to_reg=%b, branch=%b, mem_read=%b", 
        reg_write, alu_src, mem_write, alu_op, mem_to_reg, branch, mem_read);
    
    // Test I-type instruction (load)
    opcode = 7'b0000011; // I-type (load)
    #1;
    $display("lw: reg_write=%b, alu_src=%b, mem_write=%b, alu_op=%b, mem_to_reg=%b, branch=%b, mem_read=%b", 
        reg_write, alu_src, mem_write, alu_op, mem_to_reg, branch, mem_read);
    
    // Test S-type instruction (store)
    opcode = 7'b0100011; // S-type (store)
    #1;
    $display("sw: reg_write=%b, alu_src=%b, mem_write=%b, alu_op=%b, mem_to_reg=%b, branch=%b, mem_read=%b", 
        reg_write, alu_src, mem_write, alu_op, mem_to_reg, branch, mem_read);

    // Test B-type instruction (branch)
    opcode = 7'b1100011; // B-type (branch)
    #1;
    $display("beq: reg_write=%b, alu_src=%b, mem_write=%b, alu_op=%b, mem_to_reg=%b, branch=%b, mem_read=%b", 
        reg_write, alu_src, mem_write, alu_op, mem_to_reg, branch, mem_read);

    $finish;
end
endmodule