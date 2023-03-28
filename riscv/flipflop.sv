`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Module Name: flipflop
// Description:  An edge-triggered register
//  When reset is `1`, the value of the register is set to 0.
//  Otherwise:
//    - if stall is set, the register preserves its original data
//    - else, it is updated by `d`.
//////////////////////////////////////////////////////////////////////////////////
//单个信号过PC

module flipflop # (
    parameter WIDTH = 32
)(
    input  logic clock,
    input  logic reset,
    input  logic flush,
    input  logic [WIDTH-1:0] d,
    input  logic stall,
    output logic [WIDTH-1:0] q
);

    always_ff @(posedge clock, posedge reset)
    begin
        if (reset|flush)
            q <= 0;
        else if (~stall)
            q <= d;
    end


endmodule
