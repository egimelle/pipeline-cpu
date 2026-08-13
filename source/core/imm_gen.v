module imm_gen(
    input [31:0] instruction,
    output reg [31:0] imm_out
);

wire [6:0] opcode = instruction[6:0];

always @(*) begin
    case (opcode)
        7'b0000011, 7'b0010011: //i-type
            imm_out = {{20{instruction[31]}}, instruction[31:20]};
        7'b0100011: //s-type
            imm_out = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
        7'b1100011: //b-type
            imm_out = {{19{instruction[31]}}, instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0};
            default: imm_out = 32'b0;
    endcase
end
endmodule