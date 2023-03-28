`timescale 1ns / 1ps

module Proc_controller(

    //Input
    input logic [6:0] Opcode, //instruction

    //Outputs
    output logic ALUSrc,    //0: The second ALU operand comes from the second register file output (Read data 2);
                  //1: The second ALU operand is the sign-extended, lower 16 bits of the instruction.
    output logic MemtoReg, //0: The value fed to the register Write data input comes from the ALU.
                     //1: The value fed to the register Write data input comes from the data memory.
    output logic RegWrite, //The register on the Write register input is written with the value
                           // on the Write data input
    output logic MemRead,  //Data memory contents designated by the address input are put on the Read data output
    output logic MemWrite, //Data memory contents designated by the address input are replaced by 
                           //the value on the Write data input.
    output logic [1:0] ALUOp,   //00: LW/SW/AUIPC; 01:Branch; 10: Rtype/Itype; 11:JAL/LUI
    output logic Branch,  //0: branch is not taken; 1: branch is taken/jal
    output logic JalrSel,      //0: Jalr is not taken; 1: jalr is taken
    output logic [1:0] RWSel    //00£ºRegister Write Back; 01: PC+4 write back(JAL/JALR); 
                                //10: imm-gen write back(LUI); 11: pc+imm-gen write back(AUIPC)
);
initial begin
    ALUSrc = 0;
    MemtoReg = 0;
    RegWrite = 0;
    MemRead = 0;
    MemWrite = 0;
    ALUOp = 00;
    Branch = 0;
    JalrSel=0;
    RWSel = 00;
end

    always@(*)
    begin
        case(Opcode)
            7'b0110011:
            //RType
            begin
                ALUSrc = 0;
                MemtoReg = 0;
                RegWrite = 1;
                MemRead = 0;
                MemWrite = 0;
                ALUOp = 10;
                Branch = 0;
                JalrSel=0;
                RWSel = 00;
            end
            7'b0000011:
            //lw
            begin
                ALUSrc = 1;
                MemtoReg = 1;
                RegWrite = 1;
                MemRead = 1;
                MemWrite = 0;
                ALUOp = 00;
                Branch = 0;
                JalrSel=0;
                RWSel = 00;
            end
            7'b0010011:
            //andi
            begin
                ALUSrc = 1;
                MemtoReg = 0;
                RegWrite = 1;
                MemRead = 0;
                MemWrite = 0;
                ALUOp = 10;
                Branch = 0;
                JalrSel=0;
                RWSel = 00;
            end
            7'b0100011:
            //sw
            begin
                ALUSrc = 1;
                MemtoReg = 0;
                RegWrite = 0;
                MemRead = 0;
                MemWrite = 1;
                ALUOp = 00;
                Branch = 0;
                JalrSel=0;
                RWSel = 00;
            end
            7'b1100011:
            //beq
            begin
                ALUSrc = 0;
                MemtoReg = 0;
                RegWrite = 0;
                MemRead = 0;
                MemWrite = 0;
                ALUOp = 01;
                Branch = 1;
                JalrSel=0;
                RWSel = 00;
            end
            7'b1100111:
            //jalr
            begin
                ALUSrc = 1;
                MemtoReg = 0;
                RegWrite = 1;
                MemRead = 0;
                MemWrite = 0;
                ALUOp = 11;
                Branch = 0;
                JalrSel= 1;
                RWSel = 01;
            end
            7'b0110111:
            //lui
            begin
                ALUSrc = 0;
                MemtoReg = 0;
                RegWrite = 1;
                MemRead = 0;
                MemWrite = 0;
                ALUOp = 11;
                Branch = 0;
                JalrSel= 0;
                RWSel = 10;
            end
            7'b1101111:
            //jal:jump imm20
            begin
                ALUSrc = 1;
                MemtoReg = 0;
                RegWrite = 1;
                MemRead = 0;
                MemWrite = 0;
                ALUOp = 11;
                Branch = 1;
                JalrSel= 1;
                RWSel = 01;
            end
            default:
            begin
                ALUSrc = 0;
                MemtoReg = 0;
                RegWrite = 0;
                MemRead = 0;
                MemWrite = 0;
                ALUOp = 00;
                Branch = 0;
                JalrSel=0;
                RWSel = 00;
            end
        endcase
    end

endmodule
