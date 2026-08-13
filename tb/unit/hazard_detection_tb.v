`timescale 1ns/1ps;
module hazard_detection_tb;
reg id_ex_mem_read;
reg [4:0] id_ex_rd;
reg [4:0] if_id_rs1, if_id_rs2;
wire pc_write, if_id_write, control_mux_sel;
hazard_detection uut(
    .id_ex_mem_read(id_ex_mem_read),
    .id_ex_rd(id_ex_rd),
    .if_id_rs1(if_id_rs1),
    .if_id_rs2(if_id_rs2),
    .pc_write(pc_write),
    .if_id_write(if_id_write),
    .control_mux_sel(control_mux_sel)
);
initial begin
    id_ex_mem_read = 1;
    id_ex_rd = 5'd6;
    if_id_rs1 = 5'd6;
    if_id_rs2 = 5'd8;
    #10;
    $display("Test (load-use rs1): pc_write = %b (expect 0), if_id_write = %b (expect 0), stall = %b (expect 1)", pc_write, if_id_write, control_mux_sel);

    id_ex_mem_read = 1;
    id_ex_rd = 5'd8;
    if_id_rs1 = 5'd6;
    if_id_rs2 = 5'd8;
    #10;
    $display("Test2 (load-use rs2): stall=%b (expect 1)", control_mux_sel);

    id_ex_mem_read = 0;
    id_ex_rd = 5'd6;
    if_id_rs1 = 5'd6;
    if_id_rs2 = 5'd8;
    #10;
    $display("Test3 (not load): pc_write=%b (expect 1), stall=%b (expect 0)", pc_write, control_mux_sel);

    id_ex_mem_read = 1;
    id_ex_rd = 5'd10;
    if_id_rs1 = 5'd6;
    if_id_rs2 = 5'd8;
    #10;
    $display("Test4 (no match): stall=%b (expect 0)", control_mux_sel);

    id_ex_mem_read = 1;
    id_ex_rd = 5'd0;
    if_id_rs1 = 5'd0;
    if_id_rs2 = 5'd8;
    #10;
    $display("Test5 (x0 excluded): stall=%b (expect 0)", control_mux_sel);

end
endmodule
