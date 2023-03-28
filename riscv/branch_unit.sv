`timescale 1ns / 1ps
module BranchUnit #(
)(
    input  logic [31:0]        cur_pc,
    input  logic [31:0]        imm,
    input  logic               jalr_sel,
    input  logic               branch_taken,    // Branch
    input  logic [31:0]        alu_result,
    output logic [31:0]        pc_plus_4,       // PC + 4
    output logic [31:0]        imm_out,
    output logic [31:0]        branch_target,   // BrPC
    output logic               pc_sel
);

    assign imm_out=imm;
    assign pc_plus_4=cur_pc+4;
    assign pc_sel=((alu_result)&(branch_taken==1)&(jalr_sel==0))|(jalr_sel==1);
    always@(*)
    begin
        if(branch_taken==1)//branch+jal
        begin
            branch_target=cur_pc+imm;//+32'd4;
        end
        else if((branch_taken==0)&(jalr_sel==1))//jalr
        begin
            branch_target=(alu_result+imm)&(32'b11111111111111111111111111111110);
        end
        else
        begin
            branch_target=0;
        end
    end
    
endmodule
