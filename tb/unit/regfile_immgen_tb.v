`timescale 1ns / 1ps
module regfile_immgen_tb;

    reg clk;
    reg reg_write;
    reg [4:0] rs1, rs2, rd;
    reg [31:0] write_data;
    wire [31:0] read_data1, read_data2;
    reg [31:0] test_instr;
    wire [31:0] imm_out;

register_file rf_inst (
    .clk(clk),
    .reg_write(reg_write),
    .rs1(rs1),
    .rs2(rs2),
    .rd(rd),
    .write_data(write_data),
    .read_data1(read_data1),
    .read_data2(read_data2)
);
imm_gen imm_inst (
    .instruction(test_instr),
    .imm_out(imm_out)
);

initial clk = 0;
always #5 clk = ~clk;

initial begin
    $dumpfile("regfile_immgen_tb.vcd");
    $dumpvars(0, regfile_immgen_tb);

    reg_write = 1;
    rd = 5'd5;
    write_data = 32'd42;
    rs1 = 5'd5;
    rs2 = 5'd0;
    #10;

    reg_write = 0;
    #10;
    $display("regfile test : read_data1 (x5) = %0d, (wait for 42)", read_data1);
    $display("regfile test : read_data2 (x0) = %0d, (wait for 0)", read_data2);

    test_instr = 32'h00500093;
    #1;
    $display("imm_gen test : imm_out = %0d, (wait for 5)", imm_out);

    test_instr = 32'h00112223;
    #1;
    $display("imm_gen test : imm_out = %0d, (wait for 4)", imm_out);

    $finish;
end
endmodule
