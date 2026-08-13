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
    alu_control = 4'b0000; #1;
        $display("ADD: 10+3 = %0d (expect 13), zero=%b", result, zero);

        alu_control = 4'b0001; #1;
        $display("SUB: 10-3 = %0d (expect 7), zero=%b", result, zero);

        alu_control = 4'b0010; #1;
        $display("AND: 10&3 = %0d (expect 2), zero=%b", result, zero);

        alu_control = 4'b0011; #1;
        $display("OR:  10|3 = %0d (expect 11), zero=%b", result, zero);

        alu_control = 4'b0101; #1;
        $display("SLT: 10<3 = %0d (expect 0), zero=%b", result, zero);

        a = 5; b = 5;
        alu_control = 4'b0001; #1;
        $display("SUB: 5-5 = %0d (expect 0), zero=%b (expect 1)", result, zero);

        $finish;
end
endmodule
