`timescale 1ns/1ps
module forwarding_unit_tb;
    reg [4:0] ex_rs1;
    reg [4:0] ex_rs2;
    reg [4:0] mem_rd;
    reg mem_reg_write;
    reg [4:0] wb_rd;
    reg wb_reg_write;

    wire [1:0] forward_a;
    wire [1:0] forward_b;
    forwarding_unit uut(
        .ex_rs1(ex_rs1),
        .ex_rs2(ex_rs2),
        .mem_rd(mem_rd),
        .mem_reg_write(mem_reg_write),
        .wb_rd(wb_rd),
        .wb_reg_write(wb_reg_write),
        .forward_a(forward_a),
        .forward_b(forward_b)
    );
    initial begin
        ex_rs1 = 5'd1; ex_rs2 = 5'd2;
        mem_rd = 5'd3; mem_reg_write = 1;
        wb_rd = 5'd4; wb_reg_write = 1;
        #10;
        $display("Test1 (no hazard): forward_a=%b (expect 00), forward_b=%b (expect 00)", forward_a, forward_b);

        ex_rs1 = 5'd1; ex_rs2 = 5'd2;
        mem_rd = 5'd1; mem_reg_write = 1;
        wb_rd = 5'd4; wb_reg_write = 1;
        #10;
        $display("Test2 (EX/MEM hazard rs1): forward_a=%b (expect 10), forward_b=%b (expect 00)", forward_a, forward_b);

        ex_rs1 = 5'd1; ex_rs2 = 5'd2;
        mem_rd = 5'd3; mem_reg_write = 1;
        wb_rd = 5'd2; wb_reg_write = 1;
        #10;
        $display("Test3 (MEM/WB hazard rs2): forward_a=%b (expect 00), forward_b=%b (expect 01)", forward_a, forward_b);

        ex_rs1 = 5'd1; ex_rs2 = 5'd2;
        mem_rd = 5'd1; mem_reg_write = 1;
        wb_rd = 5'd1; wb_reg_write = 1;
        #10;
        $display("Test4 (priority EX/MEM): forward_a=%b (expect 10, EX/MEM wins)", forward_a);

        ex_rs1 = 5'd0; ex_rs2 = 5'd2;
        mem_rd = 5'd0; mem_reg_write = 1;
        wb_rd = 5'd4; wb_reg_write = 1;
        #10;
        $display("Test5 (x0 excluded): forward_a=%b (expect 00, x0 never forwarded)", forward_a);

        ex_rs1 = 5'd1; ex_rs2 = 5'd2;
        mem_rd = 5'd1; mem_reg_write = 0;
        wb_rd = 5'd4; wb_reg_write = 1;
        #10;
        $display("Test6 (reg_write=0): forward_a=%b (expect 00, reg_write must be 1)", forward_a);

        $finish;
    end
endmodule
