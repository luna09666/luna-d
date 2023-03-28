`timescale 1ns / 1ps

`include "pipeline_regs.sv"
import Pipe_Buf_Reg_PKG::*;

module Datapath #(
    parameter PC_W = 9, // Program Counter
    parameter INS_W = 32, // Instruction Width
    parameter DATA_W = 32, // Data WriteData
    parameter DM_ADDRESS = 9, // Data Memory Address
    parameter ALU_CC_W = 4 // ALU Control Code Width
)(
    input  logic clock,
    input  logic reset,        // reset , sets the PC to zero
    input  logic reg_write_en, // Register file writing enable
    input  logic MemtoReg,     // Memory or ALU MUX
    input  logic alu_src,      // Register file or Immediate MUX
    input  logic mem_write_en, // Memroy Writing Enable
    input  logic mem_read_en,  // Memroy Reading Enable
    input  logic branch_taken, // Branch Enable
    input  logic jalr_sel,     // Jalr Mux Select
    input  logic [1:0] alu_op,
    input  logic [1:0] RWSel,  // Mux4to1 Select
    input  logic [ALU_CC_W -1:0] alu_cc, // ALU Control Code ( input of the ALU )

    output logic [6:0] opcode,
    output logic [6:0] funct7,
    output logic [2:0] funct3,
    output logic [1:0] aluop_current,
    output logic [DATA_W-1:0] wb_data // data write back to register
);

    // ====================================================================================
    //                                Instruction Fetch (IF)
    // ====================================================================================
    //
    // peripheral logic here.
    //
    logic PcSel;
    logic stall;
    logic [31:0]BrPC;
    logic [31:0]PC;
    logic [31:0]PC_wow;
    logic [31:0]PC_id;
    logic [31:0]insn_id,insn;
    logic [1:0]aluop_current_mem;
    //
    // add your instruction memory
    //
    logic jstall,bstall;
    
    assign PC_wow=PcSel?BrPC:(PC+32'd4);
    //flipflop flipflop(.clock(clock),.reset(reset),.flush(BrFlush),.d(PC_wow),.stall(Stall),.q(PC));
    always @(posedge clock,negedge reset)
    begin
        if (reset)
        begin
            PC<=32'b0;
        end
        else if (~stall)//(~(stall|jstall))
        begin
            PC<=PC_wow;
        end
        // add your logic here to update the IF_ID_Register
    end
    initial begin
        PC<=32'b0;
    end
    Insn_mem Insn_mem(.read_address(PC),.insn(insn));
    assign jstall=(PcSel!=1&(insn[6:0]==7'b1101111|insn[6:0]==7'b1100111))?1:0;
    assign opcode=insn_id[6:0];
    // ====================================================================================
    //                             End of Instruction Fetch (IF)
    // ====================================================================================

    
    always @(posedge clock)
    begin
        if (PcSel)
        begin
            PC_id<=0;
            insn_id<=0;
        end
        else if (~stall)
        begin
            PC_id<=PC;
            insn_id<=insn;
        end
        // add your logic here to update the IF_ID_Register
    end


    // ====================================================================================
    //                                Instruction Decoding (ID)
    // ====================================================================================

    //
    // peripheral logic here.
    //
    logic [4:0]rd_wb,rd,RS1,RS2,rs1_id,rs2_id;
    logic [31:0]RD1,RD2,immG,RD1_ex,RD2_ex,imm;
    logic [31:0]PC_ex;
    logic ALUSrc_ex,MemtoReg_ex,Branch_ex,MemWrite_ex,MemRead_ex,RegWrite_ex,JalrSel_ex;
    logic [1:0]RWSel_ex;
    //
    // add your register file here.
    //
    assign rs1_id=insn_id[19:15];
    assign rs2_id=insn_id[24:20];
    Reg_file Reg_file(.clock(clock),.reset(reset),.write_en(reg_write_en),.write_addr(rd_wb),.data_in(wb_data), // data that supposed to be written into the register file
                      .read_addr1(rs1_id),.read_addr2(rs2_id),.data_out1(RD1),.data_out2(RD2));
    

    //
    // add your immediate generator here
    //
    Imm_gen Imm_gen(.inst_code(insn_id),.imm_out(immG));

    // ====================================================================================
    //                                End of Instruction Decoding (ID)
    // ====================================================================================


    always @(posedge clock)
    begin
        if (PcSel)//|stall)
        begin
            ALUSrc_ex<=0;
            MemtoReg_ex<=0;
            Branch_ex<=0;
            MemWrite_ex<=0;
            MemRead_ex<=0;
            aluop_current<=0;
            RegWrite_ex<=0;
            JalrSel_ex<=0;
            RWSel_ex<=0;
            PC_ex<=0;
            RD1_ex<=0;
            RD2_ex<=0;
            imm<=0;
            RS1<=0;
            RS2<=0;
            rd<=0;
            funct3<=0;
            funct7<=0;
        end
        else
        begin
            ALUSrc_ex<=alu_src;
            MemtoReg_ex<=MemtoReg;
            Branch_ex<=branch_taken;
            MemWrite_ex<=mem_write_en;
            MemRead_ex<=mem_read_en;
            aluop_current<=alu_op;
            RegWrite_ex<=reg_write_en;
            JalrSel_ex<=jalr_sel;
            RWSel_ex<=RWSel;
            PC_ex<=PC_id;
            RD1_ex<=RD1;
            RD2_ex<=RD2;
            imm<=immG;
            RS1<=rs1_id;
            RS2<=rs2_id;
            rd<=insn_id[11:7];
            funct7<=(insn_id[6:0]==7'b0110011)?insn_id[31:25]:insn_id[6:0];
            funct3<=insn_id[14:12];
        end
        // add your logic here to update the ID_EX_Register
    end


    // ====================================================================================
    //                                    Execution (EX)
    // ====================================================================================
    logic [1:0]RWSel_mem;
    logic [31:0]alu_result,pc_plus_4,imm_out,alu_result_mem,ALUdata_a,ALUdata_b,RD2_ex_FB,RD2_mem,result_mem;
    logic [1:0]forward_a,forward_b;
    logic [31:0]z;
    logic RegWrite_mem,MemWrite_mem,MemRead_mem,MemtoReg_mem,signal;
    logic [31:0]pc_plus_4_mem,imm_out_mem;
    logic [4:0]rd_mem;
    logic [2:0]funct3_mem;
    assign z=0;
    
    //
    // add your ALU, branch unit and with peripheral logic here
    //
    BranchUnit BranchUnit(.cur_pc(PC_ex),.imm(imm),
                            .jalr_sel(JalrSel_ex),.branch_taken(Branch_ex),.alu_result(alu_result),
                            .imm_out(imm_out),.pc_plus_4(pc_plus_4),.branch_target(BrPC),
                            .pc_sel(PcSel));
    alu alu(.operand_a(ALUdata_a),.operand_b(ALUdata_b),.alu_ctrl(alu_cc),.alu_result(alu_result));
    mux4 mux4(.d00(RD1_ex),.d01(wb_data),.d10(result_mem),.d11(z),.s(forward_a),.y(ALUdata_a));
    mux4 mux41(.d00(RD2_ex),.d01(wb_data),.d10(result_mem),.d11(z),.s(forward_b),.y(RD2_ex_FB));
    mux2 mux2(.d0(RD2_ex_FB),.d1(imm),.s(ALUSrc_ex),.y(ALUdata_b));
    // ====================================================================================
    //                                End of Execution (EX)
    // ====================================================================================


    always @(posedge clock)
    begin
            RegWrite_mem<=RegWrite_ex;
            MemWrite_mem<=MemWrite_ex;
            MemRead_mem<=MemRead_ex;
            MemtoReg_mem<=MemtoReg_ex;
            RWSel_mem<=RWSel_ex;
            pc_plus_4_mem<=pc_plus_4;
            imm_out_mem<=imm_out;
            alu_result_mem<=alu_result;
            RD2_mem<=RD2_ex;
            rd_mem<=rd;
            funct3_mem<=funct3;
            aluop_current_mem<=aluop_current;
       
        // add your logic here to update the EX_MEM_Register
    end


    // ====================================================================================
    //                                    Memory Access (MEM)
    // ====================================================================================
    logic [31:0]ReadData,pc_plus_4_wb,imm_out_wb,ReadData_wb,alu_result_wb;
    logic RegWrite_wb,MemtoReg_wb;
    logic [1:0]RWSel_wb;
    // add your data memory here.
    mux4 mux43(.d00(alu_result_mem),.d01(pc_plus_4_mem),.d10(imm_out_mem),.d11(z),.s(RWSel_mem),.y(result_mem));
    datamemory datamemory(.clock(clock),.read_en(MemRead_mem),.write_en(MemWrite_mem),
                        .address(alu_result_mem),.data_in(RD2_mem),.funct3(funct3_mem),
                        .data_out(ReadData));
    // ====================================================================================
    //                                End of Memory Access (MEM)
    // ====================================================================================


    always @(posedge clock)
    begin
        if(reset)
        begin
            RegWrite_wb<=0;
            MemtoReg_wb<=0;
            RWSel_wb<=0;
            pc_plus_4_wb<=0;
            imm_out_wb<=0;
            ReadData_wb<=0;
            alu_result_wb<=0;
            rd_wb<=0;
        end
        else
        begin
            RegWrite_wb<=RegWrite_mem;
            MemtoReg_wb<=MemtoReg_mem;
            RWSel_wb<=RWSel_mem;
            pc_plus_4_wb<=pc_plus_4_mem;
            imm_out_wb<=imm_out_mem;
            ReadData_wb<=ReadData;
            alu_result_wb<=alu_result_mem;
            rd_wb<=rd_mem;
        end
        // add your logic here to update the MEM_WB_Register
    end


    // ====================================================================================
    //                                  Write Back (WB)
    // ====================================================================================

    //
    // add your write back logic here.
    //
    logic [31:0]Mem_out;
    //logic JalrSel;
    //assign JalrSel=jalr_sel;
    mux2 mux21(.d0(alu_result_wb),.d1(ReadData_wb),.s(MemtoReg_wb),.y(Mem_out));
    mux4 mux42(.d00(Mem_out),.d01(pc_plus_4_wb),.d10(imm_out_wb),.d11(z),.s(RWSel_wb),.y(wb_data));

    // ====================================================================================
    //                               End of Write Back (WB)
    // ====================================================================================


    // ====================================================================================
    //                                   other logic
    // ====================================================================================

    //
    // add your hazard detection logic here
    //
    logic branch,jalr_h;
    assign branch=(insn[6:0]==7'b1100011)?1:0;
    assign jalr_h=(insn_id[6:0]==7'b1101111|insn[6:0]==7'b1100111)?1:0;
    assign signal=(aluop_current==2'b01)?1:0;
    assign bstall=branch&(~signal)&(~jalr_h);
    Hazard_detector Hazard_detector(.if_id_rs1(rs1_id),.if_id_rs2(rs2_id),
                                   .id_ex_rd(rd),.id_ex_memread(MemRead_ex),.stall(stall),.signal(signal),
                                   .branch_id(branch_taken),.memtoreg_mem(MemtoReg_mem),.ex_mem_rd(rd_mem));

    //
    // add your forwarding logic here
    //
    ForwardingUnit ForwardingUnit(.rs1(RS1),.rs2(RS2),.ex_mem_rd(rd_mem),.mem_wb_rd(rd_wb),.ex_mem_regwrite(RegWrite_mem),
                   .mem_wb_regwrite(RegWrite_wb),.forward_a(forward_a),.forward_b(forward_b));

    //
    // possible extra code
    //


endmodule