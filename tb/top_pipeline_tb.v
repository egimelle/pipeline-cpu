`timescale 1ns/1ps
module top_pipeline_tb;

    reg clk;
    reg rst;

    top_pipeline top_pipeline_inst(
        .clk(clk),
        .rst(rst)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("top_pipeline_tb.vcd");
        $dumpvars(0, top_pipeline_tb);

        clk=0;
        rst=1;
        #12;
        rst=0;
        #100;
        $finish;
    end
    initial begin
        $monitor("Time: %0t if_instr=%h id_instr=%h pc_out=%0d",
        $time, top_pipeline_inst.if_instruction, top_pipeline_inst.id_instruction, top_pipeline_inst.if_pc_out);
    end
endmodule