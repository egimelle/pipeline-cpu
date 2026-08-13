`timescale 1ns/1ps

module top_pipeline_flush_tb;
reg clk, rst;

top_pipeline top_pipeline_inst(
    .clk(clk),
    .rst(rst)
);
always #5 clk = ~clk;

initial begin 
    $dumpfile("flush_tb.vcd");
    $dumpvars(0, top_pipeline_flush_tb);

    clk = 0;
    rst = 1;
    #12;
    rst = 0;

    #150;

    $display("---- Final registers ----");
        $display("x1 = %d (expect 1)", top_pipeline_inst.id_stage_inst.register_file_inst.registers[1]);
        $display("x6 = %d (expect 0, must be flushed!)", top_pipeline_inst.id_stage_inst.register_file_inst.registers[6]);
        $display("x7 = %d (expect 2)", top_pipeline_inst.id_stage_inst.register_file_inst.registers[7]);

        $finish;
end
initial begin
    $monitor("t=%0t | pc=%0d | pc_src=%b flush=%b | if_instr=%h id_instr=%h",
            $time,
            top_pipeline_inst.if_pc_out,
            top_pipeline_inst.pc_src,
            top_pipeline_inst.flush,
            top_pipeline_inst.if_instruction,
            top_pipeline_inst.id_instruction);
end

endmodule