`timescale 1ns/1ps
module forwarding_unit_tb;
    reg [4:0] id_ex_rs1;
    reg [4:0] id_ex_rs2;
    reg [4:0] ex_mem_rd;
    reg ex_mem_reg_write;
    reg [4:0] mem_wb_rd;
    reg mem_wb_reg_write;

    wire [1:0] forward_a;
    wire [1:0] forward_b;
forwarding_unit uut(
        .id_ex_rs1(id_ex_rs1),
        .id_ex_rs2(id_ex_rs2),
        .ex_mem_rd(ex_mem_rd),
        .ex_mem_reg_write(ex_mem_reg_write),
        .mem_wb_rd(mem_wb_rd),
        .mem_wb_reg_write(mem_wb_reg_write),
        .forward_a(forward_a),
        .forward_b(forward_b)
    );  
    initial begin
        // ---------- тест 1: нет hazard ----------
        id_ex_rs1 = 5'd1; id_ex_rs2 = 5'd2;
        ex_mem_rd = 5'd3; ex_mem_reg_write = 1;
        mem_wb_rd = 5'd4; mem_wb_reg_write = 1;
        #10;
        $display("Test1 (no hazard): forward_a=%b (expect 00), forward_b=%b (expect 00)", forward_a, forward_b);

        // ---------- тест 2: EX/MEM hazard на rs1 ----------
        id_ex_rs1 = 5'd1; id_ex_rs2 = 5'd2;
        ex_mem_rd = 5'd1; ex_mem_reg_write = 1;   // rd совпадает с rs1!
        mem_wb_rd = 5'd4; mem_wb_reg_write = 1;
        #10;
        $display("Test2 (EX/MEM hazard rs1): forward_a=%b (expect 10), forward_b=%b (expect 00)", forward_a, forward_b);

        // ---------- тест 3: MEM/WB hazard на rs2 ----------
        id_ex_rs1 = 5'd1; id_ex_rs2 = 5'd2;
        ex_mem_rd = 5'd3; ex_mem_reg_write = 1;
        mem_wb_rd = 5'd2; mem_wb_reg_write = 1;   // rd совпадает с rs2!
        #10;
        $display("Test3 (MEM/WB hazard rs2): forward_a=%b (expect 00), forward_b=%b (expect 01)", forward_a, forward_b);

        // ---------- тест 4: приоритет EX/MEM над MEM/WB ----------
        id_ex_rs1 = 5'd1; id_ex_rs2 = 5'd2;
        ex_mem_rd = 5'd1; ex_mem_reg_write = 1;   // и EX/MEM, и MEM/WB совпадают с rs1
        mem_wb_rd = 5'd1; mem_wb_reg_write = 1;
        #10;
        $display("Test4 (priority EX/MEM): forward_a=%b (expect 10, EX/MEM wins)", forward_a);

        // ---------- тест 5: rd=x0 не должен форвардиться ----------
        id_ex_rs1 = 5'd0; id_ex_rs2 = 5'd2;
        ex_mem_rd = 5'd0; ex_mem_reg_write = 1;   // rd=0, но rs1 тоже 0 — не должно форвардиться!
        mem_wb_rd = 5'd4; mem_wb_reg_write = 1;
        #10;
        $display("Test5 (x0 excluded): forward_a=%b (expect 00, x0 never forwarded)", forward_a);

        // ---------- тест 6: reg_write=0 не должен форвардиться ----------
        id_ex_rs1 = 5'd1; id_ex_rs2 = 5'd2;
        ex_mem_rd = 5'd1; ex_mem_reg_write = 0;   // rd совпадает, но reg_write=0!
        mem_wb_rd = 5'd4; mem_wb_reg_write = 1;
        #10;
        $display("Test6 (reg_write=0): forward_a=%b (expect 00, reg_write must be 1)", forward_a);

        $finish;
    end
endmodule