
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//»°÷∏¡Ó


module Insn_mem #(
    parameter ADDR_WIDTH = 32,
    parameter INSN_WIDTH = 32
)(
    input  logic [ADDR_WIDTH - 1 : 0] read_address,
    output logic [INSN_WIDTH - 1 : 0] insn
);

    logic [INSN_WIDTH-1 :0] insn_array [127:0];

    initial begin
        $display("reading from insn.txt...");
        //$readmemh("insn.txt", insn_array);
        $readmemh( "D:/jisuanjixitong/riscv_sv/insn.txt",insn_array);
        $display("finished reading from insn.txt...");
    end

    assign insn = insn_array[read_address[9:2]];

endmodule