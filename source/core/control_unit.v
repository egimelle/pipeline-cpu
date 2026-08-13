//control_unit.v
module control_unit(
    input [6:0] opcode,

    output reg reg_write,
    output reg alu_src,
    output reg mem_write,
    output reg [1:0] alu_op,
    output reg mem_to_reg,
    output reg branch,
    output reg mem_read
);

    always @(*) begin
        case (opcode)
            7'b0110011: begin // R-type
                reg_write = 1;
                alu_src = 0;
                mem_write = 0;
                alu_op = 2'b10;
                mem_to_reg = 0;
                branch = 0;
                mem_read = 0;
            end
            7'b0010011: begin // I-type (arithmetic)
                reg_write = 1;
                alu_src = 1;
                mem_write = 0;
                alu_op = 2'b10; 
                mem_to_reg = 0;
                branch = 0;
                mem_read = 0;
            end
            7'b0000011: begin // I-type (load)
                reg_write = 1;
                alu_src = 1;
                mem_write = 0;
                alu_op = 2'b00;
                mem_to_reg = 1;
                branch = 0;
                mem_read = 1;
            end
            7'b0100011: begin // S-type (store)
                reg_write = 0;
                alu_src = 1;
                mem_write = 1;
                alu_op = 2'b00;
                mem_to_reg = 0; // don't care
                branch = 0;
                mem_read = 0;
            end
            7'b1100011: begin // B-type (branch)
                reg_write = 0;
                alu_src = 0; // don't care
                mem_write = 0;
                alu_op = 2'b01; // for branch comparison
                mem_to_reg = 0; // don't care
                branch = 1;
                mem_read = 0;
            end
            default: begin // default case for unsupported opcodes
                reg_write = 0;
                alu_src = 0; // don't care
                mem_write = 0;
                alu_op = 2'b00; // default ALU operation
                mem_to_reg = 0; // don't care
                branch = 0; // no branching
                mem_read = 0; // no memory read
            end
        endcase
    end
endmodule