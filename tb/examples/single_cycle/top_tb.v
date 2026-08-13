`timescale 1ns/1ps
module top_tb;
reg clk;
reg rst;

top uut (
    .clk(clk),
    .rst(rst)
);

always #5 clk = ~clk;

initial begin 
    $dumpfile ("top_tb.vcd");
    $dumpvars(0, top_tb);

    clk = 0;
    rst = 1;

    #12;
    rst = 0;

    
    #200;
    $display("x1 = %d", uut.register_file_inst.registers[1]);
    $display("x2 = %d", uut.register_file_inst.registers[2]);
    $display("x3 = %d", uut.register_file_inst.registers[3]);
    $display("x4 = %d", uut.register_file_inst.registers[4]);
    $display("x5 = %d", uut.register_file_inst.registers[5]);
    $display("x6 = %d", uut.register_file_inst.registers[6]);

    $finish;

end

initial begin
    $monitor("t=%0t pc=%0d instr=%h reg_write=%b alu_result=%d",
        $time, uut.pc_out, uut.instruction, uut.reg_write, uut.alu_result);
    end

endmodule