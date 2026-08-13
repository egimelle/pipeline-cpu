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

        clk = 0;
        rst = 1;
        #12;
        rst = 0;

        #200;

        // финальные значения регистров (через иерархию до regfile внутри id_stage)
        $display("---- Final registers ----");
        $display("x1 = %d", top_pipeline_inst.id_stage_inst.register_file_inst.registers[1]);
        $display("x2 = %d", top_pipeline_inst.id_stage_inst.register_file_inst.registers[2]);
        $display("x3 = %d", top_pipeline_inst.id_stage_inst.register_file_inst.registers[3]);
        $display("x4 = %d", top_pipeline_inst.id_stage_inst.register_file_inst.registers[4]);
        $display("x5 = %d", top_pipeline_inst.id_stage_inst.register_file_inst.registers[5]);
        $display("x6 = %d", top_pipeline_inst.id_stage_inst.register_file_inst.registers[6]);

        $finish;
    end

    initial begin
        $monitor("t=%0t | IF=%h | ID=%h | EX_alu=%0d | MEM_alu=%0d | WB_data=%0d",
            $time,
            top_pipeline_inst.if_instruction,
            top_pipeline_inst.id_instruction,
            top_pipeline_inst.ex_alu_result,
            top_pipeline_inst.mem_alu_result,
            top_pipeline_inst.wb_write_back_data
        );
    end

endmodule