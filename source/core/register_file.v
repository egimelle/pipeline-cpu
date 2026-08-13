module register_file (
    input clk,
    input reg_write,

    input [4:0] rs1,
    input [4:0] rs2,
    input [4:0] rd,
    input [31:0] write_data,

    output [31:0] read_data1,
    output [31:0] read_data2
    );
    reg [31:0] registers[0:31];

    integer i;
    initial begin
        for (i = 0; i < 32; i = i + 1)
            registers[i] = 32'b0;
    end

    assign read_data1 = (rs1 == 5'b0) ? 32'b0 : registers[rs1];
    assign read_data2 = (rs2 == 5'b0) ? 32'b0 : registers[rs2];

    // written on the falling edge so a same-cycle WB write is visible
    // to ID's read well before the next rising edge (write-first behavior
    // without an explicit WB->ID forwarding path)
    always @(negedge clk) begin
        if (reg_write && (rd != 5'b0)) begin
            registers[rd] <= write_data;
        end
    end
endmodule
