module hazard_detection(
    input id_ex_mem_read,
    input [4:0] id_ex_rd,
    input [4:0] if_id_rs1, 
    input [4:0] if_id_rs2,

    output reg pc_write,
    output reg if_id_write,
    output reg control_mux_sel
);
    always @(*) begin
        if (id_ex_mem_read && ((id_ex_rd == if_id_rs1) || (id_ex_rd == if_id_rs2)) && (id_ex_rd != 5'b0)) begin
            pc_write = 1'b0;
            if_id_write = 1'b0;
            control_mux_sel = 1'b1;
        end else begin
            pc_write = 1'b1;
            if_id_write = 1'b1;
            control_mux_sel = 1'b0;
        end
    end
endmodule