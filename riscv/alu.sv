`timescale 1ns / 1ps

module alu #(
    parameter DATA_WIDTH    = 32,
    parameter OPCODE_LENGTH = 4
)(
    input  logic[DATA_WIDTH - 1 : 0]    operand_a,
    input  logic[DATA_WIDTH - 1 : 0]    operand_b,
    input  logic[OPCODE_LENGTH - 1 : 0] alu_ctrl,   // Operation
    output logic[DATA_WIDTH - 1    : 0] alu_result
);
always_comb
    case(alu_ctrl)
        4'b0000:alu_result=operand_a+operand_b; //add
        4'b0001:alu_result=operand_a-operand_b; //sub
        4'b0010:alu_result=operand_a|operand_b; //or
        4'b0011:alu_result=operand_a&operand_b; //and
        4'b0100:alu_result=(operand_a<operand_b)? 1:0; //slt blt
        4'b0101:alu_result=operand_a^operand_b; //xor
        4'b0110:alu_result=($signed(operand_a)>=$signed(operand_b))?1:0; //bgeu
        4'b0111:alu_result=($signed(operand_a)<$signed(operand_b))?1:0; //bltu
        4'b1000:alu_result=(operand_a>=operand_b)?1:0; //bge
        4'b1001:alu_result=(operand_a!=operand_b)?1:0; //bne
        default:alu_result=32'b0;
    endcase

endmodule

