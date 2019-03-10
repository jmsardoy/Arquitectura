`timescale 1ns / 1ps

`include "constants.vh"

module Execution
#(
    parameter PC_BITS          = `PC_BITS,
    parameter INSTRUCTION_BITS = `INSTRUCTION_BITS,
    parameter PROC_BITS        = `PROC_BITS,
    parameter REG_ADDRS_BITS   = `REG_ADDRS_BITS,
    parameter OPCODE_BITS      = `OPCODE_BITS
)
(
    input wire [PC_BITS - 1 : 0]        i_PCNext,
    input wire [OPCODE_BITS - 1 : 0]    i_opcode,
    input wire [PROC_BITS - 1 : 0]      i_read_data_1,
    input wire [PROC_BITS - 1 : 0]      i_read_data_2,
    input wire [PROC_BITS - 1 : 0]      i_immediate_data_ext,
    input wire [PC_BITS - 1 : 0]        i_jump_address, 
    input wire [REG_ADDRS_BITS - 1 : 0] i_rs,
    input wire [REG_ADDRS_BITS - 1 : 0] i_rt,
    input wire [REG_ADDRS_BITS - 1 : 0] i_rd,


    //control inputs
    input wire       i_branch_enable,
    input wire       i_RegDst,
    input wire       i_RegWrite,
    input wire       i_MemRead,
    input wire       i_MemWrite,
    input wire       i_MemtoReg,
    input wire [3:0] i_ALUOp,
    input wire       i_ALUSrc,
    input wire       i_Shamt,
    input wire [2:0] i_ls_filter_op,

    //inputs of data for fowarding
    input wire [PROC_BITS - 1 : 0] i_ex_mem_data,
    input wire [PROC_BITS - 1 : 0] i_mem_wb_data,

    //inputs for FowardingUnit
    input wire i_ex_mem_RegWrite,
    input wire i_mem_wb_RegWrite,
    input wire [REG_ADDRS_BITS - 1 : 0] i_ex_mem_rd,
    input wire [REG_ADDRS_BITS - 1 : 0] i_mem_wb_rd,

    //outputs purely from execution stage
    output wire [PROC_BITS - 1 : 0]      o_alu_result,
    output wire [PROC_BITS - 1 : 0]      o_rt_data, //data for store instruction
    output wire [REG_ADDRS_BITS - 1 : 0] o_rd,

    //outputs from BranchUnit
    output wire o_taken,
    output wire o_pc_to_reg,
    output wire [PC_BITS - 1 : 0] o_jump_address,
    output wire [PC_BITS - 1 : 0] o_pc_return,

    //outputs from control
    output wire o_RegWrite,
    output wire o_MemRead,
    output wire o_MemWrite,
    output wire o_MemtoReg,
    output wire [2:0] o_ls_filter_op
);

    //assign control signals
    assign o_RegWrite     = i_RegWrite;
    assign o_MemRead      = i_MemRead;
    assign o_MemWrite     = i_MemWrite;
    assign o_MemtoReg     = i_MemtoReg;
    assign o_ls_filter_op = i_ls_filter_op;

    //wire for ALU and ALUControl conection
    wire [3 : 0] operation;
    wire [5 : 0] funct;
    assign funct = i_immediate_data_ext[5:0];

    //wires for multiplexors for alu inputs
    wire [1:0] fowardA;
    wire [1:0] fowardB;
    wire [PROC_BITS - 1 : 0] foward_data_a;
    wire [PROC_BITS - 1 : 0] foward_data_b;
    wire [PROC_BITS - 1 : 0] alu_input_1;
    wire [PROC_BITS - 1 : 0] alu_input_2;
    wire [PROC_BITS - 1 : 0] shamt_data;

    //wire for control signal from BranchUnit (internal)
    wire pc_reg_sel;


    //destination register mux
    wire [REG_ADDRS_BITS - 1 : 0] rd_aux;
    assign rd_aux = (i_RegDst) ? i_rd : i_rt;
    assign o_rd   = (pc_reg_sel) ? {REG_ADDRS_BITS{1'b1}} : rd_aux;


    //shamt extraction from immediate
    assign shamt_data = { {27{1'b0}} ,i_immediate_data_ext[10:6]};


    //alu inputs muxs

    //fowarding mux A
    assign foward_data_a = (fowardA == 'b10) ? i_ex_mem_data :
                           (fowardA == 'b01) ? i_mem_wb_data :
                                               i_read_data_1 ;
    //fowarding mux B
    assign foward_data_b = (fowardB == 'b10) ? i_ex_mem_data :
                           (fowardB == 'b01) ? i_mem_wb_data :
                                               i_read_data_2 ;
    //shamt mux
    assign alu_input_1 = (i_Shamt)  ? shamt_data      : foward_data_a;

    //immediate mux
    assign alu_input_2 = (i_ALUSrc) ? i_immediate_data_ext : foward_data_b;

    
    //rt data output for store operation
    assign o_rt_data = foward_data_b;


    ALUControl alu_control_u (
        .i_ALUOp(i_ALUOp),
        .i_funct(funct),
        .o_operation(operation)
    );

    ALU alu_u(
        .i_dataA(alu_input_1), 
        .i_dataB(alu_input_2), 
        .i_operation(operation),
        .o_result(o_alu_result)
    );
    
    BranchUnit branch_unit_u(
        .i_branch_enable(i_branch_enable),
        .i_opcode(i_opcode),
        .i_funct(funct),
        .i_pc_next(i_PCNext),
        .i_immediate(i_immediate_data_ext),
        .i_jump_address(i_jump_address),
        .i_data_rs(foward_data_a),
        .i_data_rt(foward_data_b),
        .o_taken(o_taken),
        .o_pc_to_reg(o_pc_to_reg),
        .o_jump_address(o_jump_address),
        .o_pc_return(o_pc_return),
        .o_pc_reg_sel(pc_reg_sel)
    );

    FowardingUnit foward_unit_u(
        .i_ex_mem_RegWrite(i_ex_mem_RegWrite),
        .i_mem_wb_RegWrite(i_mem_wb_RegWrite),
        .i_id_ex_rs(i_rs),
        .i_id_ex_rt(i_rt),
        .i_ex_mem_rd(i_ex_mem_rd),
        .i_mem_wb_rd(i_mem_wb_rd),
        .o_foward_A(fowardA),
        .o_foward_B(fowardB)
    );









endmodule

