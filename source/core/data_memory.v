module data_memory(
    input clk,
    input mem_read,
    input mem_write,
    input [31:0] addr,
    input [31:0] write_data,

    output [31:0] read_data
);
reg [31:0] mem [0:63];

always @(posedge clk) begin
    if(mem_write)
    mem[addr[31:2]] <= write_data;
end

assign read_data = mem_read ? mem[addr[31:2]] : 32'b0;

endmodule