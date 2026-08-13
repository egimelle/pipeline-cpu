`timescale 1ns/1ps

module alu_control_tb;
    reg [1:0] alu_op;
    reg [2:0] funct3;
    reg funct7;
    reg is_rtype;
    wire [3:0] alu_control;

alu_control alu_control_inst (
    .alu_op(alu_op),
    .funct3(funct3),
    .funct7(funct7),
    .is_rtype(is_rtype),
    .alu_control(alu_control)
);
initial begin
    $dumpfile("alu_control_tb.vcd");
    $dumpvars(0, alu_control_tb);

        alu_op = 2'b10; funct3 = 3'b000; funct7 = 0; is_rtype = 1; #1;
        $display("add:  alu_ctrl=%b (expect 0000)", alu_control);

        alu_op = 2'b10; funct3 = 3'b000; funct7 = 1; is_rtype = 1; #1;
        $display("sub:  alu_ctrl=%b (expect 0001)", alu_control);

        alu_op = 2'b10; funct3 = 3'b000; funct7 = 1; is_rtype = 0; #1;
        $display("addi: alu_ctrl=%b (expect 0000)", alu_control);

        alu_op = 2'b10; funct3 = 3'b111; funct7 = 0; is_rtype = 1; #1;
        $display("and:  alu_ctrl=%b (expect 0010)", alu_control);

        alu_op = 2'b00; funct3 = 3'b000; funct7 = 0; is_rtype = 0; #1;
        $display("lw/sw: alu_ctrl=%b (expect 0000)", alu_control);

        alu_op = 2'b01; funct3 = 3'b000; funct7 = 0; is_rtype = 0; #1;
        $display("beq:  alu_ctrl=%b (expect 0001)", alu_control);

    $finish;
end
endmodule
