`timescale 1ps/1ps

module HazardDetectionUnit(
    input clk,
    input Branch_ID, rs1use_ID, rs2use_ID,
    input[1:0] hazard_optype_ID,
    input[4:0] rd_EXE, rd_MEM, rs1_ID, rs2_ID, rs2_EXE,
    output PC_EN_IF, reg_FD_EN, reg_FD_stall, reg_FD_flush,
        reg_DE_EN, reg_DE_flush, reg_EM_EN, reg_EM_flush, reg_MW_EN,
    output forward_ctrl_ls,
    output[1:0] forward_ctrl_A, forward_ctrl_B,
    input DatatoReg_MEM, DatatoReg_EXE, MIO
);
    //according to the diagram, design the Hazard Detection Unit
    
    // forward_ctrl_A : rs1
    wire a0 = rs1use_ID == 1 & rs1_ID != 0 & rs1_ID != rd_EXE & rs1_ID != rd_MEM;
    wire a1 = rs1use_ID == 1 & rs1_ID != 0 & rs1_ID == rd_EXE & ~DatatoReg_EXE;
    wire a2 = rs1use_ID == 1 & rs1_ID != 0 & rs1_ID != rd_EXE & rs1_ID == rd_MEM & ~DatatoReg_MEM;
    wire a3 = rs1use_ID == 1 & rs1_ID != 0 & rs1_ID != rd_EXE & rs1_ID == rd_MEM & DatatoReg_MEM;
    assign forward_ctrl_A = {2{a0}} & 2'b00 |
                            {2{a1}} & 2'b01 |
                            {2{a2}} & 2'b10 |
                            {2{a3}} & 2'b11;

    // forward_ctrl_B : rs2
    wire b0 = rs2use_ID == 1 & rs2_ID != 0 & rs2_ID != rd_EXE & rs2_ID != rd_MEM;
    wire b1 = rs2use_ID == 1 & rs2_ID != 0 & rs2_ID == rd_EXE & ~DatatoReg_EXE;
    wire b2 = rs2use_ID == 1 & rs2_ID != 0 & rs2_ID != rd_EXE & rs2_ID == rd_MEM & ~DatatoReg_MEM;
    wire b3 = rs2use_ID == 1 & rs2_ID != 0 & rs2_ID != rd_EXE & rs2_ID == rd_MEM & DatatoReg_MEM;
    assign forward_ctrl_B = {2{b0}} & 2'b00 |
                            {2{b1}} & 2'b01 |
                            {2{b2}} & 2'b10 |
                            {2{b3}} & 2'b11;

    // forward_ctrl_ls
    assign forward_ctrl_ls = DatatoReg_MEM & rd_MEM == rs2_EXE & rs2_EXE != 0;

    assign PC_EN_IF = ~reg_FD_stall;
    assign reg_FD_EN = 1'b1;
    assign reg_FD_stall =   ( rd_EXE == rs1_ID & rs1_ID != 0 & rs1use_ID == 1 
                            | rd_EXE == rs2_ID & rs2_ID != 0 & rs2use_ID == 1) 
                            & DatatoReg_EXE & ~MIO; 
    assign reg_FD_flush = Branch_ID;
    assign reg_DE_EN = 1'b1;
    assign reg_DE_flush = reg_FD_stall;
    assign reg_EM_EN = 1'b1;
    assign reg_EM_flush = 1'b0;
    assign reg_MW_EN = 1'b1;
endmodule