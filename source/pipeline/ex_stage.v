module ex_stage(
    input [31:0] pc,
    input [31:0] read_data1,
    input [31:0] read_data2,
    input [31:0] imm_out,
    input [1:0] alu_op,
    input alu_src,
    input [2:0] funct3,
    input funct7,
    input is_rtype,

    input [1:0] forward_a,
    input [1:0] forward_b,
    input [31:0] mem_alu_result_fwd,
    input [31:0] wb_write_back_data,

    output [31:0] alu_result,
    output zero,
    output [31:0] branch_target,
    output [31:0] store_data
);

    reg [31:0] alu_in_a;
    reg [31:0] read_data2_fwd;

    always @(*) begin
        case (forward_a)
            2'b10:   alu_in_a = mem_alu_result_fwd;
            2'b01:   alu_in_a = wb_write_back_data;
            default: alu_in_a = read_data1;
        endcase

        case (forward_b)
            2'b10:   read_data2_fwd = mem_alu_result_fwd;
            2'b01:   read_data2_fwd = wb_write_back_data;
            default: read_data2_fwd = read_data2;
        endcase
    end

    wire [31:0] alu_b;
    assign alu_b = alu_src ? imm_out : read_data2_fwd;

    wire [3:0] alu_control_signal;
    alu_control alu_control_inst(
        .alu_op(alu_op),
        .funct3(funct3),
        .funct7(funct7),
        .is_rtype(is_rtype),
        .alu_control(alu_control_signal)
    );

    alu alu_inst(
        .a(alu_in_a),
        .b(alu_b),
        .alu_control(alu_control_signal),
        .result(alu_result),
        .zero(zero)
    );

    assign branch_target = pc + imm_out;
    assign store_data = read_data2_fwd;
endmodule
