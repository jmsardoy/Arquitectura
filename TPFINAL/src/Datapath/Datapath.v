`timescale 1ns / 1ps

`include "constants.vh"

module Datapath
#(
    parameter PC_BITS          = `PC_BITS,
    parameter INSTRUCTION_BITS = `INSTRUCTION_BITS,
    parameter PROC_BITS        = `PROC_BITS,
    parameter REG_ADDRS_BITS   = `REG_ADDRS_BITS,
    parameter OPCODE_BITS      = `OPCODE_BITS,
    parameter DATA_ADDRS_BITS  = `DATA_ADDRS_BITS,

    parameter IF_ID_LEN  = `IF_ID_LEN,
    parameter ID_EX_LEN  = `ID_EX_LEN,
    parameter EX_MEM_LEN = `EX_MEM_LEN,
    parameter MEM_WB_LEN = `MEM_WB_LEN,
    parameter RF_REGS_LEN = `RF_REGS_LEN
)
(
    input wire clk,
    input wire rst,
    input wire enable,

    //inputs from debug for loading instruction memory
    input wire                            i_write_inst_mem,
    input wire [PC_BITS - 1 : 0]          i_inst_mem_addr,
    input wire [INSTRUCTION_BITS - 1 : 0] i_inst_mem_data,

    //inputs from debug for reading data memory
    input                           i_debug_read_data,
    input [DATA_ADDRS_BITS - 1 : 0] i_debug_read_address,

    //outputs for debug
    output wire [RF_REGS_LEN - 1 : 0] o_rf_regs,
    output wire [IF_ID_LEN - 1 : 0]   o_if_id_signals,
    output wire [ID_EX_LEN - 1 : 0]   o_id_ex_signals,
    output wire [EX_MEM_LEN - 1 : 0]  o_ex_mem_signals,
    output wire [MEM_WB_LEN - 1 : 0]  o_mem_wb_signals,
    output wire [PROC_BITS - 1 : 0]   o_mem_data
);

    //wires for InstructionFetch and IF_ID latch connection
    wire [PC_BITS - 1 : 0]          if_PCNext;
    wire [INSTRUCTION_BITS - 1 : 0] if_instruction;

    //wires for IF_ID latch and InstructionDecoder connection
    wire [PC_BITS - 1 : 0]          if_id_PCNext;
    wire [INSTRUCTION_BITS - 1 : 0] if_id_instruction;

    assign o_if_id_signals = {if_id_PCNext, 
                            if_id_instruction};

    //wires for InstructionDecoder and ID_EX latch connection
    wire [PC_BITS - 1 : 0]     id_PCNext;
    wire [OPCODE_BITS - 1 : 0] id_opcode;
    wire                       id_PCWrite;
    wire                       id_if_id_write;
    wire       id_RegDst;
    wire       id_RegWrite;
    wire       id_MemRead;
    wire       id_MemWrite;
    wire       id_MemtoReg;
    wire [3:0] id_ALUOp;
    wire       id_ALUSrc;
    wire       id_Shamt;
    wire [2:0] id_ls_filter_op;
    wire       id_branch_enable;
    wire [PROC_BITS - 1 : 0] id_read_data_1;
    wire [PROC_BITS - 1 : 0] id_read_data_2;
    wire [PROC_BITS - 1 : 0] id_immediate_data_ext;
    wire [PC_BITS - 1 : 0]   id_jump_address;
    wire [REG_ADDRS_BITS - 1 : 0] id_rs;
    wire [REG_ADDRS_BITS - 1 : 0] id_rt;
    wire [REG_ADDRS_BITS - 1 : 0] id_rd;

    //wires for ID_EX latch en Execution connection
    wire [PC_BITS - 1 : 0] id_ex_PCNext;
    wire [OPCODE_BITS - 1 : 0] id_ex_opcode;
    wire [PROC_BITS - 1 : 0] id_ex_read_data_1;
    wire [PROC_BITS - 1 : 0] id_ex_read_data_2;
    wire [PROC_BITS - 1 : 0] id_ex_immediate_data_ext;
    wire [PC_BITS - 1 : 0] id_ex_jump_address;
    wire [REG_ADDRS_BITS - 1 : 0] id_ex_rs;
    wire [REG_ADDRS_BITS - 1 : 0] id_ex_rt;
    wire [REG_ADDRS_BITS - 1 : 0] id_ex_rd;
    wire       id_ex_RegDst;
    wire       id_ex_RegWrite;
    wire       id_ex_MemRead;
    wire       id_ex_MemWrite;
    wire       id_ex_MemtoReg;
    wire [3:0] id_ex_ALUOp;
    wire       id_ex_ALUSrc;
    wire       id_ex_Shamt;
    wire [2:0] id_ex_ls_filter_op;
    wire       id_ex_branch_enable;

    assign o_id_ex_signals = {id_ex_PCNext,
                              id_ex_opcode,
                              id_ex_read_data_1,
                              id_ex_read_data_2,
                              id_ex_immediate_data_ext,
                              id_ex_jump_address,
                              id_ex_rs,
                              id_ex_rt,
                              id_ex_rd,
                              id_ex_RegDst,
                              id_ex_RegWrite,
                              id_ex_MemRead,
                              id_ex_MemWrite,
                              id_ex_MemtoReg,
                              id_ex_ALUOp,
                              id_ex_ALUSrc,
                              id_ex_Shamt,
                              id_ex_ls_filter_op,
                              id_ex_branch_enable};

    //wires for Execution and EX_MEM latch connection
    wire [PROC_BITS - 1 : 0]      ex_alu_result;
    wire [PROC_BITS - 1 : 0]      ex_rt_data;
    wire [REG_ADDRS_BITS - 1 : 0] ex_rd;
    wire ex_taken;
    wire ex_pc_to_reg;
    wire [PC_BITS - 1 : 0] ex_jump_address;
    wire [PC_BITS - 1 : 0] ex_pc_return;
    wire       ex_RegWrite;
    wire       ex_MemRead;
    wire       ex_MemWrite;
    wire       ex_MemtoReg;
    wire [2:0] ex_ls_filter_op;

    //wires for EX_MEM latch and MemoryStage connection
    wire [PROC_BITS - 1 : 0]      ex_mem_alu_result;
    wire [PROC_BITS - 1 : 0]      ex_mem_rt_data;
    wire [REG_ADDRS_BITS - 1 : 0] ex_mem_rd;
    wire       ex_mem_RegWrite;
    wire       ex_mem_MemRead;
    wire       ex_mem_MemWrite;
    wire       ex_mem_MemtoReg;
    wire [2:0] ex_mem_ls_filter_op;
    wire ex_mem_taken;
    wire ex_mem_pc_to_reg;
    wire [PC_BITS - 1 : 0] ex_mem_jump_address;
    wire [PC_BITS - 1 : 0] ex_mem_pc_return;

    assign o_ex_mem_signals = {ex_mem_alu_result,
                               ex_mem_rt_data,
                               ex_mem_rd,
                               ex_mem_RegWrite,
                               ex_mem_MemRead,
                               ex_mem_MemWrite,
                               ex_mem_MemtoReg,
                               ex_mem_ls_filter_op,
                               ex_mem_taken,
                               ex_mem_pc_to_reg,
                               ex_mem_jump_address,
                               ex_mem_pc_return};

    //wires for MemoryStage and MEM_WB connection
    wire [PROC_BITS - 1 : 0]      mem_alu_data;
    wire [PROC_BITS - 1 : 0]      mem_mem_data;
    wire [REG_ADDRS_BITS - 1 : 0] mem_rd;
    wire mem_pc_to_reg;
    wire [PC_BITS - 1 : 0] mem_pc_return;
    wire mem_RegWrite;
    wire mem_MemtoReg;

    assign o_mem_data = mem_mem_data;

    //wires for MEM_WB and WriteBack connection
    wire [PROC_BITS - 1 : 0]      mem_wb_alu_data;
    wire [PROC_BITS - 1 : 0]      mem_wb_mem_data;
    wire [REG_ADDRS_BITS - 1 : 0] mem_wb_rd;
    wire mem_wb_pc_to_reg;
    wire [PC_BITS - 1 : 0] mem_wb_pc_return;
    wire mem_wb_RegWrite;
    wire mem_wb_MemtoReg;

    assign o_mem_wb_signals = {mem_wb_alu_data,
                               mem_wb_mem_data,
                               mem_wb_rd,
                               mem_wb_pc_to_reg,
                               mem_wb_pc_return,
                               mem_wb_RegWrite,
                               mem_wb_MemtoReg};

    //wire for WriteBack output
    wire [PROC_BITS - 1 : 0] wb_data;

    InstructionFetch IF_u(
        .clk(clk),
        .rst(rst),
        .enable(enable),
        .i_PCWrite(id_PCWrite),
        .i_PCSrc(ex_mem_taken),
        .i_PCBranch(ex_mem_jump_address),
        .i_write_inst_mem(i_write_inst_mem),
        .i_inst_mem_addr(i_inst_mem_addr),
        .i_inst_mem_data(i_inst_mem_data),
        .o_PCNext(if_PCNext),
        .o_instruction(if_instruction)
    );

    IF_ID if_id_latch(
        .clk(clk),
        .rst(rst),
        .enable(enable),
        .flush(ex_mem_taken),
        .i_if_id_write(id_if_id_write),
        .i_PCNext(if_PCNext),
        .i_instruction(if_instruction),
        .o_PCNext(if_id_PCNext),
        .o_instruction(if_id_instruction)
        
    );

    InstructionDecoder ID_u(
        .clk(clk),
        .i_instruction(if_id_instruction),
        .i_PCNext(if_id_PCNext),
        .i_write_data(wb_data),
        .i_mem_wb_rd(mem_wb_rd),
        .i_mem_wb_RegWrite(mem_wb_RegWrite),
        .i_id_ex_rt(id_ex_rt),
        .i_id_ex_MemRead(id_ex_MemRead),
        .o_PCNext(id_PCNext),
        .o_opcode(id_opcode),
        .o_PCWrite(id_PCWrite),
        .o_if_id_write(id_if_id_write),
        .o_RegDst(id_RegDst),
        .o_RegWrite(id_RegWrite),
        .o_MemRead(id_MemRead),
        .o_MemWrite(id_MemWrite),
        .o_MemtoReg(id_MemtoReg),
        .o_ALUOp(id_ALUOp),
        .o_ALUSrc(id_ALUSrc),
        .o_Shamt(id_Shamt),
        .o_ls_filter_op(id_ls_filter_op),
        .o_branch_enable(id_branch_enable),
        .o_read_data_1(id_read_data_1),
        .o_read_data_2(id_read_data_2),
        .o_immediate_data_ext(id_immediate_data_ext),
        .o_jump_address(id_jump_address),
        .o_rs(id_rs),
        .o_rt(id_rt),
        .o_rd(id_rd),
        .o_rf_regs(o_rf_regs)
    );

    ID_EX id_ex_latch(
        .clk(clk),
        .rst(rst),
        .enable(enable),
        .flush(ex_mem_taken),
        .i_PCNext(id_PCNext),
        .i_opcode(id_opcode),
        .i_read_data_1(id_read_data_1),
        .i_read_data_2(id_read_data_2),
        .i_immediate_data_ext(id_immediate_data_ext),
        .i_jump_address(id_jump_address),
        .i_rs(id_rs),
        .i_rt(id_rt),
        .i_rd(id_rd),
        .i_RegDst(id_RegDst),
        .i_RegWrite(id_RegWrite),
        .i_MemRead(id_MemRead),
        .i_MemWrite(id_MemWrite),
        .i_MemtoReg(id_MemtoReg),
        .i_ALUOp(id_ALUOp),
        .i_ALUSrc(id_ALUSrc),
        .i_Shamt(id_Shamt),
        .i_ls_filter_op(id_ls_filter_op),
        .i_branch_enable(id_branch_enable),
        .o_PCNext(id_ex_PCNext),
        .o_opcode(id_ex_opcode),
        .o_read_data_1(id_ex_read_data_1),
        .o_read_data_2(id_ex_read_data_2),
        .o_immediate_data_ext(id_ex_immediate_data_ext),
        .o_jump_address(id_ex_jump_address),
        .o_rs(id_ex_rs),
        .o_rt(id_ex_rt),
        .o_rd(id_ex_rd),
        .o_RegDst(id_ex_RegDst),
        .o_RegWrite(id_ex_RegWrite),
        .o_MemRead(id_ex_MemRead),
        .o_MemWrite(id_ex_MemWrite),
        .o_MemtoReg(id_ex_MemtoReg),
        .o_ALUOp(id_ex_ALUOp),
        .o_ALUSrc(id_ex_ALUSrc),
        .o_Shamt(id_ex_Shamt),
        .o_ls_filter_op(id_ex_ls_filter_op),
        .o_branch_enable(id_ex_branch_enable)
    );

    Execution exec_u (
        .i_PCNext(id_ex_PCNext),
        .i_opcode(id_ex_opcode),
        .i_read_data_1(id_ex_read_data_1),
        .i_read_data_2(id_ex_read_data_2),
        .i_immediate_data_ext(id_ex_immediate_data_ext),
        .i_jump_address(id_ex_jump_address),
        .i_rs(id_ex_rs),
        .i_rt(id_ex_rt),
        .i_rd(id_ex_rd),
        .i_branch_enable(id_ex_branch_enable),
        .i_RegDst(id_ex_RegDst),
        .i_RegWrite(id_ex_RegWrite),
        .i_MemRead(id_ex_MemRead),
        .i_MemWrite(id_ex_MemWrite),
        .i_MemtoReg(id_ex_MemtoReg),
        .i_ALUOp(id_ex_ALUOp),
        .i_ALUSrc(id_ex_ALUSrc),
        .i_Shamt(id_ex_Shamt),
        .i_ls_filter_op(id_ex_ls_filter_op),
        .i_ex_mem_data(ex_mem_alu_result),
        .i_mem_wb_data(wb_data),
        .i_ex_mem_RegWrite(ex_mem_RegWrite),
        .i_mem_wb_RegWrite(mem_wb_RegWrite),
        .i_ex_mem_rd(ex_mem_rd),
        .i_mem_wb_rd(mem_wb_rd),
        
        .o_alu_result(ex_alu_result),
        .o_rt_data(ex_rt_data),
        .o_rd(ex_rd),
        .o_taken(ex_taken),
        .o_pc_to_reg(ex_pc_to_reg),
        .o_jump_address(ex_jump_address),
        .o_pc_return(ex_pc_return),
        .o_RegWrite(ex_RegWrite),
        .o_MemRead(ex_MemRead),
        .o_MemWrite(ex_MemWrite),
        .o_MemtoReg(ex_MemtoReg),
        .o_ls_filter_op(ex_ls_filter_op)
    );

    EX_MEM ex_mem_latch(
        .clk(clk),
        .rst(rst),
        .enable(enable),
        .flush(ex_mem_taken),
        .i_alu_result(ex_alu_result),
        .i_rt_data(ex_rt_data),
        .i_rd(ex_rd),
        .i_RegWrite(ex_RegWrite),
        .i_MemRead(ex_MemRead),
        .i_MemWrite(ex_MemWrite),
        .i_MemtoReg(ex_MemtoReg),
        .i_ls_filter_op(ex_ls_filter_op),
        .i_taken(ex_taken),
        .i_pc_to_reg(ex_pc_to_reg),
        .i_jump_address(ex_jump_address),
        .i_pc_return(ex_pc_return),
        .o_alu_result(ex_mem_alu_result),
        .o_rt_data(ex_mem_rt_data),
        .o_rd(ex_mem_rd),
        .o_RegWrite(ex_mem_RegWrite),
        .o_MemRead(ex_mem_MemRead),
        .o_MemWrite(ex_mem_MemWrite),
        .o_MemtoReg(ex_mem_MemtoReg),
        .o_ls_filter_op(ex_mem_ls_filter_op),
        .o_taken(ex_mem_taken),
        .o_pc_to_reg(ex_mem_pc_to_reg),
        .o_jump_address(ex_mem_jump_address),
        .o_pc_return(ex_mem_pc_return)
    );

    MemoryStage mem_stage_u(
        .clk(clk),
        .enable(enable),
        .i_alu_data(ex_mem_alu_result),
        .i_store_data(ex_mem_rt_data),
        .i_rd(ex_mem_rd),
        .i_pc_to_reg(ex_mem_pc_to_reg),
        .i_pc_return(ex_mem_pc_return),
        .i_RegWrite(ex_mem_RegWrite),
        .i_MemRead(ex_mem_MemRead),
        .i_MemWrite(ex_mem_MemWrite),
        .i_MemtoReg(ex_mem_MemtoReg),
        .i_debug_read_data(i_debug_read_data),
        .i_debug_read_address(i_debug_read_address),
        .i_ls_filter_op(ex_mem_ls_filter_op),
        .o_alu_data(mem_alu_data),
        .o_mem_data(mem_mem_data),
        .o_rd(mem_rd),
        .o_pc_to_reg(mem_pc_to_reg),
        .o_pc_return(mem_pc_return),
        .o_RegWrite(mem_RegWrite),
        .o_MemtoReg(mem_MemtoReg)
    );

    /*
    MEM_WB mem_wb_latch(
        .clk(clk),
        .rst(rst),
        .enable(enable),
        .i_alu_data(mem_alu_data),
        .i_mem_data(mem_mem_data),
        .i_rd(mem_rd),
        .i_RegWrite(ex_mem_RegWrite),   //bypass mem stage for better timming
        .i_MemtoReg(mem_MemtoReg),
        .i_pc_to_reg(mem_pc_to_reg),
        .i_pc_return(mem_pc_return),
        .o_alu_data(mem_wb_alu_data),
        .o_mem_data(mem_wb_mem_data),
        .o_rd(ex_mem_wb_rd),            //bypass mem stage for better timming
        .o_RegWrite(mem_wb_RegWrite),
        .o_MemtoReg(mem_wb_MemtoReg),
        .o_pc_to_reg(mem_wb_pc_to_reg),
        .o_pc_return(mem_wb_pc_return)
    );
    */
    MEM_WB mem_wb_latch(
        .clk(clk),
        .rst(rst),
        .enable(enable),
        .i_alu_data(mem_alu_data),
        .i_mem_data(mem_mem_data),
        .i_rd(mem_rd),
        .i_RegWrite(mem_RegWrite),
        .i_MemtoReg(mem_MemtoReg),
        .i_pc_to_reg(mem_pc_to_reg),
        .i_pc_return(mem_pc_return),
        .o_alu_data(mem_wb_alu_data),
        .o_mem_data(mem_wb_mem_data),
        .o_rd(mem_wb_rd),
        .o_RegWrite(mem_wb_RegWrite),
        .o_MemtoReg(mem_wb_MemtoReg),
        .o_pc_to_reg(mem_wb_pc_to_reg),
        .o_pc_return(mem_wb_pc_return)
    );

    WriteBack write_back_u(
        .i_alu_data(mem_wb_alu_data),
        .i_mem_data(mem_wb_mem_data),
        .i_pc_return(mem_wb_pc_return),
        .i_MemtoReg(mem_wb_MemtoReg),
        .i_pc_to_reg(mem_wb_pc_to_reg),
        .o_reg_data(wb_data)
    );



endmodule

