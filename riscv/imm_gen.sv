`timescale 1ns / 1ps

module Imm_gen(
    input  logic [31:0] inst_code,
    output logic [31:0] imm_out
);
    logic [19:0] imm20;
    logic [11:0] imm12;
    always@(*)
    begin
        case(inst_code[6:0])
            7'b0110111://lui
            begin
                imm20=inst_code[31:12];
                imm_out=imm20<<12;
            end
            7'b1101111://jal
            begin
                imm20={inst_code[31],inst_code[19:12],inst_code[20],inst_code[30:21]};
                imm_out={imm20[19]?12'hfff:12'h000, imm20}<<1;
            end
            7'b0010011://ori
            begin
                imm12=inst_code[31:20];
                imm_out={imm12[11]?20'hfffff:20'h00000,imm12};
            end
            7'b0000011://lb
            begin
                imm12=inst_code[31:20];
                if(inst_code[14]==1)
                    begin
                    imm_out={20'h00000,imm12};
                    end
                 else begin
                    imm_out={imm12[11]?20'hfffff:20'h00000,imm12};
                    end
            end
            7'b1100111://jalr
            begin
                imm12=inst_code[31:20];
                imm_out={imm12[11]?20'hfffff:20'h00000,imm12};
            end
            7'b0100011://sb
            begin
                imm12={inst_code[31:25],inst_code[11:7]};
                imm_out={imm12[11]?20'hfffff:20'h00000,imm12};
            end
            7'b1100011://beq
            begin
                imm12={inst_code[31],inst_code[7],inst_code[30:25],inst_code[11:8]};
                imm_out={imm12[11]?20'hfffff:20'h00000,imm12}<<1;
            end
            default: 
                imm_out=32'bx;
        endcase
    end
    // add your immediate extension logic here.

endmodule
