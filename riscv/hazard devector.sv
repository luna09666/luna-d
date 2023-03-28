`timescale 1ns / 1ps

module Hazard_detector (
    input  logic [4:0] if_id_rs1,
    input  logic [4:0] if_id_rs2,
    input  logic [4:0] id_ex_rd,
    input  logic branch_id,
    input  logic memtoreg_mem,
    input  logic [4:0]ex_mem_rd,
    input  logic signal,
    input  logic id_ex_memread,
    output logic stall
);

    logic lwstall,branchstall,bstall;
    assign lwstall=id_ex_memread&(if_id_rs1==id_ex_rd|if_id_rs2==id_ex_rd);
    //assign branchstall=(branch_id)&(~jalr)&(~signal);//&regwrite_ex&(if_id_rs1==id_ex_rd|if_id_rs2==id_ex_rd))|
    //((branch_id|branch)&memtoreg_mem&(if_id_rs1==ex_mem_rd|if_id_rs2==ex_mem_rd));
    assign bstall=(branch_id)&memtoreg_mem&(if_id_rs1==ex_mem_rd|if_id_rs2==ex_mem_rd);
    
    assign stall=lwstall|bstall;
    // define your hazard detection logic here

endmodule
