`timescale 1ns/1ps

module alu_tb;
reg [31:0] a,b;
reg [3:0] alu_control;
wire [31:0] result;
wire zero;

alu alu_inst (
    .a(a),
    .b(b),
    .alu_control(alu_control),
    .result(result),
    .zero(zero)
);

initial begin 
    $dumpfile("alu_tb.vcd");
    $dumpvars(0, alu_tb);

    a=10; b=3;
    alu_control = 4'b0000; #1; // ADD
        $display("ADD: 10+3 = %0d (ожидаем 13), zero=%b", result, zero);

        alu_control = 4'b0001; #1; // SUB
        $display("SUB: 10-3 = %0d (ожидаем 7), zero=%b", result, zero);

        alu_control = 4'b0010; #1; // AND
        $display("AND: 10&3 = %0d (ожидаем 2), zero=%b", result, zero);

        alu_control = 4'b0011; #1; // OR
        $display("OR:  10|3 = %0d (ожидаем 11), zero=%b", result, zero);

        alu_control = 4'b0101; #1; // SLT
        $display("SLT: 10<3 = %0d (ожидаем 0), zero=%b", result, zero);

        // отдельно проверим zero-флаг на реально равных числах
        a = 5; b = 5;
        alu_control = 4'b0001; #1; // SUB, 5-5=0
        $display("SUB: 5-5 = %0d (ожидаем 0), zero=%b (ожидаем 1)", result, zero);

        $finish;
end
endmodule