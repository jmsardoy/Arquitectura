`timescale 1ns / 1ps

`include "constants.vh"

module EX_MEM
#(
    parameter PC_BITS          = `PC_BITS,
    parameter PROC_BITS        = `PROC_BITS,
    parameter REG_ADDRS_BITS   = `REG_ADDRS_BITS
)
(
    input wire clk,
    input wire rst,
    input wire enable,
    input wire flush,

    //inputs purely from exec
    input wire [PROC_BITS - 1 : 0]     i_alu_result,
    input wire [PROC_BITS - 1 : 0]     i_rt_data,
    input wire [REG_ADDRS_BITS - 1 :0] i_rd,

    //control inputs
    input wire       i_RegWrite,
    input wire       i_MemRead,
    input wire       i_MemWrite,
    input wire       i_MemtoReg,
    input wire [2:0] i_ls_filter_op,

    //branch control inputs
    input wire i_taken,
    input wire i_pc_to_reg,
    input wire [PC_BITS - 1 : 0] i_jump_address,
    input wire [PC_BITS - 1 : 0] i_pc_return,

    
    //outputs purely from exec
    output reg [PROC_BITS - 1 : 0]     o_alu_result,
    output reg [PROC_BITS - 1 : 0]     o_rt_data,
    output reg [REG_ADDRS_BITS - 1 :0] o_rd,


    //control outputs
    output reg       o_RegWrite,
    output reg       o_MemRead,
    output reg       o_MemWrite,
    output reg       o_MemtoReg,
    output reg [2:0] o_ls_filter_op,

    //branch control outputs
    output reg o_taken,
    output reg o_pc_to_reg,
    output reg [PC_BITS - 1 : 0] o_jump_address,
    output reg [PC_BITS - 1 : 0] o_pc_return
);

    always@(posedge clk) begin
        if (~rst || flush) begin
            o_alu_result <= 0;
            o_rt_data    <= 0;
            o_rd         <= 0;
            
            o_RegWrite     <= 0;
            o_MemRead      <= 0;
            o_MemWrite     <= 0;
            o_MemtoReg     <= 0;
            o_ls_filter_op <= 0;

            o_taken        <= 0;
            o_pc_to_reg    <= 0;
            o_jump_address <= 0;
            o_pc_return    <= 0;
        end
        else begin
            if (enable) begin
                o_alu_result <= i_alu_result;
                o_rt_data    <= i_rt_data;
                o_rd         <= i_rd;
                
                o_RegWrite     <= i_RegWrite;
                o_MemRead      <= i_MemRead;
                o_MemWrite     <= i_MemWrite;
                o_MemtoReg     <= i_MemtoReg;
                o_ls_filter_op <= i_ls_filter_op;

                o_taken        <= i_taken;
                o_pc_to_reg    <= i_pc_to_reg;
                o_jump_address <= i_jump_address;
                o_pc_return    <= i_pc_return;
            end
        end
    end


endmodule
