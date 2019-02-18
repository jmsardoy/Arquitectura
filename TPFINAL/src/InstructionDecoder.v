`timescale 1ns / 1ps

`include "constants.vh"

module InstructionDecoder
#(
    parameter PROC_BITS        = `PROC_BITS,
    parameter INSTRUCTION_BITS = `INSTRUCTION_BITS,
    parameter REG_ADDRS_BITS   = `REG_ADDRS_BITS,
    parameter PC_BITS          = `PC_BITS,
    parameter OPCODE_BITS      = `OPCODE_BITS
)
(
    input clk,
    input rst,

    input wire [INSTRUCTION_BITS - 1 : 0] i_instruction,
    input wire [PC_BITS - 1 : 0]          i_PCNext,
    input wire [PROC_BITS - 1 : 0]        i_write_data,
    input wire [REG_ADDRS_BITS - 1 : 0]   i_mem_wb_rd,
    input wire                            i_mem_wb_RegWrite,



    //HazardDetector input
    input wire [REG_ADDRS_BITS - 1 : 0] i_id_ex_rt,
    input wire                          i_id_ex_MemRead,

    //HazardDetector output
    output wire o_PCWrite,
    output wire o_if_id_write,


    //control signals outputs
    output wire       o_RegDst,
    output wire       o_RegWrite,
    output wire       o_MemRead,
    output wire       o_MemWrite,
    output wire       o_MemtoReg,
    output wire [3:0] o_ALUOp,
    output wire       o_ALUSrc,
    output wire       o_Shamt,
    output wire       o_ls_filter_op,

    //RegisterFile/Data output
    output wire [PROC_BITS - 1 : 0] o_read_data_1,
    output wire [PROC_BITS - 1 : 0] o_read_data_2,
    output wire [PROC_BITS - 1 : 0] o_immediate_data_ext,

    //Reg Src and Dest outputs
    output wire [REG_ADDRS_BITS - 1 : 0] o_rs,
    output wire [REG_ADDRS_BITS - 1 : 0] o_rt,
    output wire [REG_ADDRS_BITS - 1 : 0] o_rd,

    //Other outputs
    output wire [PC_BITS - 1 : 0]    o_PCNext,
    output wire [OPCODE_BITS - 1 :0] o_opcode,
    output wire [PC_BITS - 1 : 0]    o_jump_address,

    //Debug output
    output wire [32*PROC_BITS - 1 : 0] o_rf_regs


);


    wire [OPCODE_BITS - 1 : 0]    opcode         = i_instruction[31:26];
    wire [REG_ADDRS_BITS - 1 : 0] rs             = i_instruction[25:21];
    wire [REG_ADDRS_BITS - 1 : 0] rt             = i_instruction[20:16];
    wire [REG_ADDRS_BITS - 1 : 0] rd             = i_instruction[15:11];
    wire [15 : 0]                 immediate_data = i_instruction[15:0];
    wire [25 : 0]                 jump_immediate = i_instruction[25:0];
    wire [5:0]                    funct          = i_instruction[5:0];

    assign o_PCNext = i_PCNext;
    assign o_opcode = opcode;


    //control mux from hazard to control unit
    wire control_mux;

    //sign extend
    assign o_immediate_data_ext = {{16{immediate_data[15]}}, immediate_data};
    assign o_jump_address       = {i_PCNext[31:26], jump_immediate};


    //Reg src and dest outputs
    assign o_rs = rs;
    assign o_rt = rt;
    assign o_rd = rd;
    

    RegisterFile RF(
        .clk(clk),
        .i_reg_write(i_mem_wb_RegWrite),
        .i_read_register_1(rs),
        .i_read_register_2(rt),
        .i_write_register(i_mem_wb_rd),
        .i_write_data(i_write_data),
        .o_read_data_1(o_read_data_1),
        .o_read_data_2(o_read_data_2),
        .o_debug_regs(o_rf_regs)
    );

    Control Control_u(
        .i_opcode(opcode),
        .i_funct(funct),
        .i_control_mux(control_mux),
        .o_RegDst(o_RegDst),
        .o_RegWrite(o_RegWrite),
        .o_MemRead(o_MemRead),
        .o_MemWrite(o_MemWrite),
        .o_MemtoReg(o_MemtoReg),
        .o_ALUOp(o_ALUOp),
        .o_ALUSrc(o_ALUSrc),
        .o_Shamt(o_Shamt),
        .o_ls_filter_op(o_ls_filter_op)
    );

    HazardDetector HazardDetector_u(
        .i_instruction_rs(rs),
        .i_instruction_rt(rt),
        .i_id_ex_rt(i_id_ex_rt),
        .i_id_ex_MemRead(i_id_ex_MemRead),
        .o_PCWrite(o_PCWrite),
        .o_if_id_write(o_if_id_write),
        .o_control_mux(control_mux)
    );


endmodule
