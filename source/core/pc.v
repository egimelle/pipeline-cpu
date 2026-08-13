module pc (
    input clk,
    input rst,
    input pc_write,
    input [31:0] pc_next,

    output reg [31:0] pc_out
);

    always @(posedge clk or posedge rst) begin
        if (rst)
            pc_out <= 32'b0;
        else if (pc_write)
            pc_out <= pc_next;
    end
endmodule
