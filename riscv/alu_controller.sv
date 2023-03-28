`timescale 1ns / 1ps

module ALU_Controller (
    input  logic [1:0] aluop,   // 2-bit opcode field from the Proc_controller
    input  logic [6:0] funct7,   // insn[31:25] or insn[6:0]
    input  logic [2:0] funct3,   // insn[14:12]
    output logic [3:0] operation //operation selection for ALU
);
initial begin
    operation=4'b0000;
end
always@(*)
    case(aluop)
        2'b10:
        case(funct3)
            3'b000:
            case(funct7)
                7'b0000000:operation=4'b0000; //add
                7'b0100000:operation=4'b0001; //sub
                7'b0010011:operation=4'b0000; //addi
                default: operation=4'bxxxx;
            endcase
            3'b110:operation=4'b0010; //or/ori
            3'b111:operation=4'b0011; //and/andi
            3'b010:operation=4'b0100; //slt(rs1-rs2<0:rd=1 else:rd=0)
            3'b100:operation=4'b0101; //xor
            default: operation=4'bxxxx;
        endcase
        2'b00:
        case(funct7)
            7'b0000011:operation=4'b0000; //lb/lh/lw/lbu/lhu(add:count addr)
            7'b0100011:operation=4'b0000; //sb/sh/sw(add:count addr)
            default: operation=4'bxxxx;
        endcase
        2'b01:
        case(funct3)
            3'b000:operation=4'b0110; //beq
            3'b001:operation=4'b1001; //bne
            3'b100:operation=4'b0100; //blt
            3'b101:operation=4'b1000; //bge
            3'b110:operation=4'b0111; //bltu
            3'b111:operation=4'b0110; //bgeu
            default: operation=4'bxxxx;
        endcase
        2'b11:
        case (funct7)
            7'b1100111:operation=4'b0000; //jalr(add:count jump destination)
            7'b1101111:operation=4'b0000; //jal(add:count jump destination)
            default: operation=4'bxxxx;
        endcase
    endcase
    // add your code here.
    
endmodule
