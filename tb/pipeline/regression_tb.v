`timescale 1ns/1ps
module regression_tb;
    reg clk, rst;

    top_pipeline uut(
        .clk(clk),
        .rst(rst)
    );

    always #5 clk = ~clk;

    // addi x2, x0, 10
    // addi x3, x0, 20
    // addi x5, x0, 2
    // addi x8, x0, 7
    // add  x1, x2, x3            EX->EX forwarding target (sub reads x1 right after)
    // sub  x4, x1, x5            forwarding EX->EX
    // lw   x6, 0(x4)
    // or   x7, x6, x8            stall after lw (load-use hazard)
    // beq  x7, x7, label         always taken -> flush
    // addi x9, x0, 100           must be flushed, never commits
    // label:
    // and  x10, x9, x9
    initial begin
        uut.if_stage_inst.instruction_memory_inst.mem[0]  = 32'h00a00113;
        uut.if_stage_inst.instruction_memory_inst.mem[1]  = 32'h01400193;
        uut.if_stage_inst.instruction_memory_inst.mem[2]  = 32'h00200293;
        uut.if_stage_inst.instruction_memory_inst.mem[3]  = 32'h00700413;
        uut.if_stage_inst.instruction_memory_inst.mem[4]  = 32'h003100b3;
        uut.if_stage_inst.instruction_memory_inst.mem[5]  = 32'h40508233;
        uut.if_stage_inst.instruction_memory_inst.mem[6]  = 32'h00022303;
        uut.if_stage_inst.instruction_memory_inst.mem[7]  = 32'h008363b3;
        uut.if_stage_inst.instruction_memory_inst.mem[8]  = 32'h00738463;
        uut.if_stage_inst.instruction_memory_inst.mem[9]  = 32'h06400493;
        uut.if_stage_inst.instruction_memory_inst.mem[10] = 32'h0094f533;

        // preload the word that `lw x6, 0(x4)` will read (x4 = 28 -> word 7)
        uut.mem_stage_inst.data_memory_inst.mem[7] = 32'd555;
    end

    initial begin
        $dumpfile("regression_tb.vcd");
        $dumpvars(0, regression_tb);

        clk = 0;
        rst = 1;
        #12;
        rst = 0;

        #300;

        $display("---- Final registers ----");
        $display("x1  = %0d (expect 30)",  uut.id_stage_inst.register_file_inst.registers[1]);
        $display("x2  = %0d (expect 10)",  uut.id_stage_inst.register_file_inst.registers[2]);
        $display("x3  = %0d (expect 20)",  uut.id_stage_inst.register_file_inst.registers[3]);
        $display("x4  = %0d (expect 28)",  uut.id_stage_inst.register_file_inst.registers[4]);
        $display("x5  = %0d (expect 2)",   uut.id_stage_inst.register_file_inst.registers[5]);
        $display("x6  = %0d (expect 555, loaded via lw)", uut.id_stage_inst.register_file_inst.registers[6]);
        $display("x7  = %0d (expect 559, or with stall+forward)", uut.id_stage_inst.register_file_inst.registers[7]);
        $display("x8  = %0d (expect 7)",   uut.id_stage_inst.register_file_inst.registers[8]);
        $display("x9  = %0d (expect 0, must be flushed!)", uut.id_stage_inst.register_file_inst.registers[9]);
        $display("x10 = %0d (expect 0)",   uut.id_stage_inst.register_file_inst.registers[10]);

        $finish;
    end

    initial begin
        $monitor("t=%0t | pc=%0d | if_id_write=%b control_mux_sel(stall)=%b | forward_a=%b forward_b=%b | flush=%b",
            $time,
            uut.if_pc_out,
            uut.if_id_write,
            uut.control_mux_sel,
            uut.forward_a,
            uut.forward_b,
            uut.flush
        );
    end

endmodule
