`timescale 1ns / 1ps
module datamemory#(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
)(
    input  logic                     clock,
	input  logic                     read_en,
    input  logic                     write_en,
    input  logic [ADDR_WIDTH -1 : 0] address,   // read/write address
    input  logic [DATA_WIDTH -1 : 0] data_in,   // write Data
    input  logic [2:0]               funct3,    // insn[14:12]
    output logic [DATA_WIDTH -1 : 0] data_out   // read data
);
    logic[31:0]RAM[127:0];
    integer i;
        initial
        begin
            for (i = 0; i < 128; i = i + 1) RAM[i] <=0;
        end

    always_ff @(posedge clock)
        if(write_en)//sw rs2->reg
            case (funct3)
                3'b000: //sb
                    RAM[address[31:2]]<={data_in[7]?8'hff:8'h00,data_in[7:0]};
                3'b001: //sh
                    RAM[address[31:2]]<={data_in[15]?16'hffff:16'h0000,data_in[15:0]};
                3'b010: //sw
                    RAM[address[31:2]]<=data_in;
                default: 
                    RAM[address[31:2]]<=32'bx;
            endcase
        else
            RAM[data_in[31:2]]<=32'bx;
      always@(*)
        if(read_en) //lw reg->rd
            case (funct3)
                3'b000: //lb
                    data_out<={RAM[address[31:2]][7]?8'hff:8'h00,RAM[address[31:2]][7:0]};
                3'b001: //lh
                    data_out<={RAM[address[31:2]][15]?16'hffff:16'h0000,RAM[address[31:2]][15:0]};
                3'b010: //lw
                    data_out<=RAM[address[31:2]];
                3'b100: //lbu
                    data_out<={8'h00,RAM[address[31:2]][7:0]};
                3'b101: //lhu
                    data_out<={16'h0000,RAM[address[31:2]][15:0]};
                default: 
                    data_out<=32'bx;
            endcase
        else
            data_out<=32'bx;
endmodule

