`timescale 1ns / 1ps

module ForwardingUnit (
    input  logic [4:0] rs1,
    input  logic [4:0] rs2,
    input  logic [4:0] ex_mem_rd,
    input  logic [4:0] mem_wb_rd,
    input  logic ex_mem_regwrite,
    input  logic mem_wb_regwrite,
    output logic [1:0] forward_a,
    output logic [1:0] forward_b
);
initial begin
forward_a=0;
forward_b=0;
end
    always@(*)
    begin
        if((rs1!=0)&(rs1==mem_wb_rd)& mem_wb_regwrite)
        begin
            forward_a=2'b01;
        end
        else if((rs1!=0)&(rs1==ex_mem_rd)& ex_mem_regwrite)
        begin
            forward_a=2'b10;
        end
        else forward_a=2'b00;
    end

    always@(*)
    begin
       if((rs2!=0)&(rs2==ex_mem_rd)& ex_mem_regwrite)
           forward_b=2'b10;
        else if((rs2!=0)&(rs2==mem_wb_rd)& mem_wb_regwrite)
            forward_b=2'b01;
        else forward_b=2'b00;
    end
    // define your forwarding logic here.

endmodule
