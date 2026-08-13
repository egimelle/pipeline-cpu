`timescale 1ns / 1ps

module pc_im_tb;

    reg clk;
    reg rst;
    wire [31:0] pc_current;
    wire [31:0] instruction;
    wire [31:0] pc_next;

    assign pc_next = pc_current + 4;

    pc pc_inst (
        .clk(clk),
        .rst(rst),
        .pc_next(pc_next),
        .pc_out(pc_current)
    );

    instruction_memory im_inst (
        .addr(pc_current),
        .instruction(instruction)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        $dumpfile("pc_im_tb.vcd");
        $dumpvars(0, pc_im_tb);

        rst = 1;
        #10;
        rst = 0;

        #50;
        $finish;
    end

    always @(posedge clk) begin
        $display("time=%0t  pc=%0d  instr=%h", $time, pc_current, instruction);
    end

endmodule