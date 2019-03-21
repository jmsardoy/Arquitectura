`timescale 1ns / 1ps

`include "constants.vh"

module ID_EX
#(
    parameter PC_BITS          = `PC_BITS,
    parameter INSTRUCTION_BITS = `INSTRUCTION_BITS,
    parameter PROC_BITS        = `PROC_BITS,
    parameter REG_ADDRS_BITS   = `REG_ADDRS_BITS,
    parameter OPCODE_BITS      = `OPCODE_BITS
)
(
    input clk,
    input rst,
    input enable,
    input flush,

    input wire [PC_BITS - 1 : 0]        i_PCNext,
    input wire [OPCODE_BITS - 1 : 0]    i_opcode,
    input wire [PROC_BITS - 1 : 0]      i_read_data_1,
    input wire [PROC_BITS - 1 : 0]      i_read_data_2,
    input wire [PROC_BITS - 1 : 0]      i_immediate_data_ext,
    input wire [PC_BITS - 1 : 0]        i_jump_address, 
    input wire [REG_ADDRS_BITS - 1 : 0] i_rs,
    input wire [REG_ADDRS_BITS - 1 : 0] i_rt,
    input wire [REG_ADDRS_BITS - 1 : 0] i_rd,


    //control
    input wire       i_RegDst,
    input wire       i_RegWrite,
    input wire       i_MemRead,
    input wire       i_MemWrite,
    input wire       i_MemtoReg,
    input wire [3:0] i_ALUOp,
    input wire       i_ALUSrc,
    input wire       i_Shamt,
    input wire [2:0] i_ls_filter_op,
    input wire       i_branch_enable,

    output reg [PC_BITS - 1 : 0]        o_PCNext,
    output reg [OPCODE_BITS - 1 : 0]    o_opcode,
    output reg [PROC_BITS - 1 :0]       o_read_data_1,
    output reg [PROC_BITS - 1 :0]       o_read_data_2,
    output reg [PROC_BITS - 1 :0]       o_immediate_data_ext,
    output reg [PC_BITS - 1 : 0]        o_jump_address, 
    output reg [REG_ADDRS_BITS - 1 : 0] o_rs,
    output reg [REG_ADDRS_BITS - 1 : 0] o_rt,
    output reg [REG_ADDRS_BITS - 1 : 0] o_rd,

    //control
    output reg       o_RegDst,
    output reg       o_RegWrite,
    output reg       o_MemRead,
    output reg       o_MemWrite,
    output reg       o_MemtoReg,
    output reg [3:0] o_ALUOp,
    output reg       o_ALUSrc,
    output reg       o_Shamt,
    output reg [2:0] o_ls_filter_op,
    output reg       o_branch_enable
);

    always@(posedge clk) begin

        if (~rst) begin
            o_PCNext             <= 0;
            o_opcode             <= 0;
            o_read_data_1        <= 0;
            o_read_data_2        <= 0;
            o_immediate_data_ext <= 0;
            o_jump_address       <= 0;
            o_rs                 <= 0;
            o_rt                 <= 0;
            o_rd                 <= 0;

            o_RegDst        <= 0;
            o_RegWrite      <= 0;
            o_MemRead       <= 0;
            o_MemWrite      <= 0;
            o_MemtoReg      <= 0;
            o_ALUOp         <= 0;
            o_ALUSrc        <= 0;
            o_Shamt         <= 0;
            o_ls_filter_op  <= 0;
            o_branch_enable <= 0;
        end
        else begin
            if (enable) begin
                if (flush) begin
                    o_PCNext             <= 0;
                    o_opcode             <= 0;
                    o_read_data_1        <= 0;
                    o_read_data_2        <= 0;
                    o_immediate_data_ext <= 0;
                    o_jump_address       <= 0;
                    o_rs                 <= 0;
                    o_rt                 <= 0;
                    o_rd                 <= 0;

                    o_RegDst        <= 0;
                    o_RegWrite      <= 0;
                    o_MemRead       <= 0;
                    o_MemWrite      <= 0;
                    o_MemtoReg      <= 0;
                    o_ALUOp         <= 0;
                    o_ALUSrc        <= 0;
                    o_Shamt         <= 0;
                    o_ls_filter_op  <= 0;
                    o_branch_enable <= 0;
                end
                else begin
                    o_PCNext             <= i_PCNext;
                    o_opcode             <= i_opcode;
                    o_read_data_1        <= i_read_data_1;
                    o_read_data_2        <= i_read_data_2;
                    o_immediate_data_ext <= i_immediate_data_ext;
                    o_jump_address       <= i_jump_address;
                    o_rs                 <= i_rs;
                    o_rt                 <= i_rt;
                    o_rd                 <= i_rd;

                    o_RegDst        <= i_RegDst;
                    o_RegWrite      <= i_RegWrite;
                    o_MemRead       <= i_MemRead;
                    o_MemWrite      <= i_MemWrite;
                    o_MemtoReg      <= i_MemtoReg;
                    o_ALUOp         <= i_ALUOp;
                    o_ALUSrc        <= i_ALUSrc;
                    o_Shamt         <= i_Shamt;
                    o_ls_filter_op  <= i_ls_filter_op;
                    o_branch_enable <= i_branch_enable;
                end
            end
        end
    end

endmodule
