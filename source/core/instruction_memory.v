module instruction_memory (
    input [31:0] addr,

    output wire [31:0] instruction
);

    reg [31:0] mem [0:63];

    initial begin
    mem[0] = 32'h00100093;
    mem[1] = 32'h00108463;
    mem[2] = 32'h3E700313;
    mem[3] = 32'h00200393;
    end

    assign instruction = mem[addr[31:2]];

endmodule
