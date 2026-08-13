`timescale 1ns/1ps

module alu_control_tb;
    reg [1:0] alu_op;
    reg [2:0] funct3;
    reg funct7;
    wire [3:0] alu_control;

alu_control alu_control_inst (
    .alu_op(alu_op),
    .funct3(funct3),
    .funct7(funct7),
    .alu_control(alu_control)
);
initial begin
    $dumpfile("alu_control_tb.vcd");
    $dumpvars(0, alu_control_tb);

    // add: alu_op=10, funct3=000, funct7_bit5=0
        alu_op = 2'b10; funct3 = 3'b000; funct7 = 0; #1;
        $display("add:  alu_ctrl=%b (ожидаем 0000)", alu_control);

        // sub: alu_op=10, funct3=000, funct7_bit5=1
        alu_op = 2'b10; funct3 = 3'b000; funct7 = 1; #1;
        $display("sub:  alu_ctrl=%b (ожидаем 0001)", alu_control);

        // and: alu_op=10, funct3=111
        alu_op = 2'b10; funct3 = 3'b111; funct7 = 0; #1;
        $display("and:  alu_ctrl=%b (ожидаем 0010)", alu_control);

        // lw/sw: alu_op=00
        alu_op = 2'b00; funct3 = 3'b000; funct7 = 0; #1;
        $display("lw/sw: alu_ctrl=%b (ожидаем 0000)", alu_control);

        // beq: alu_op=01
        alu_op = 2'b01; funct3 = 3'b000; funct7 = 0; #1;
        $display("beq:  alu_ctrl=%b (ожидаем 0001)", alu_control);

    $finish;
end
endmodule