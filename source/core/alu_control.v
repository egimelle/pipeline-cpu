//alu_control.v
module alu_control(
    input [1:0] alu_op,
    input [2:0] funct3,
    input funct7,      // instruction[30]
    input is_rtype,     // instruction[5]: 1 = R-type, 0 = I-type
    output reg [3:0] alu_control
);
    wire sub_or_add = funct7 & is_rtype; // SUB только для R-type

    always @(*) begin
        case(alu_op)
            2'b00: alu_control = 4'b0000; // load/store -> ADD
            2'b01: alu_control = 4'b0001; // branch -> SUB (для beq)
            2'b10: begin
                case(funct3)
                3'b000: alu_control = sub_or_add ? 4'b0001 : 4'b0000; // SUB(R)/ADD(R,I)
                3'b111: alu_control = 4'b0010; // AND
                3'b110: alu_control = 4'b0011; // OR
                3'b100: alu_control = 4'b0100; // XOR
                3'b010: alu_control = 4'b0101; // SLT
                default: alu_control = 4'b0000;
                endcase
            end
            default: alu_control = 4'b0000;
        endcase
    end
endmodule