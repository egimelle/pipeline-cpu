module instruction_memory (
    input [31:0] addr,
    
    output wire [31:0] instruction
);

    reg [31:0] mem [0:63];

    initial begin
    mem[0] = 32'h00100093; // addi x1, x0, 1        (t=0)
    mem[1] = 32'h00108463; // beq  x1, x1, +8        (t=1) — mem[3]
    mem[2] = 32'h3E700313; // addi x6, x0, 999       (t=2) — flush
    mem[3] = 32'h00200393; // addi x7, x0, 2         (t=3) — here
    end

    assign instruction = mem[addr[31:2]];

endmodule
