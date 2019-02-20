`timescale 1ns / 1ps

`include "constants.vh"

module MEM_WB
#(
    parameter PC_BITS         = `PC_BITS,
    parameter PROC_BITS       = `PROC_BITS,
    parameter REG_ADDRS_BITS  = `REG_ADDRS_BITS
)
(
    input wire clk,
    input wire rst,
    input wire enable,

    //inputs purely from exec
    input wire [PROC_BITS - 1 : 0]      i_alu_data,
    input wire [PROC_BITS - 1 : 0]      i_mem_data,
    input wire [REG_ADDRS_BITS - 1 : 0] i_rd,

    //control inputs
    input wire i_RegWrite,
    input wire i_MemtoReg,

    //branch control inputs
    input wire i_pc_to_reg,
    input wire [PC_BITS - 1 : 0] i_pc_return,

    //outputs purely from mem
    output reg [PROC_BITS - 1 : 0]      o_alu_data,
    output reg [PROC_BITS - 1 : 0]      o_mem_data,
    output reg [REG_ADDRS_BITS - 1 : 0] o_rd,

    //control outputs
    output reg o_RegWrite,
    output reg o_MemtoReg,

    //branch control outputs
    output reg o_pc_to_reg,
    output reg [PC_BITS - 1 : 0] o_pc_return

);

    always@(posedge clk) begin
        if (~rst) begin
            o_alu_data <= 0;
            o_mem_data <= 0;
            o_rd       <= 0;

            o_RegWrite <= 0;
            o_MemtoReg <= 0;

            o_pc_to_reg <= 0;
            o_pc_return <= 0;
        end
        else begin
            if (enable) begin
                o_alu_data <= i_alu_data;
                o_mem_data <= i_mem_data;
                o_rd       <= i_rd;

                o_RegWrite <= i_RegWrite;
                o_MemtoReg <= i_MemtoReg;

                o_pc_to_reg <= i_pc_to_reg;
                o_pc_return <= i_pc_return;
            end
        end
    end


endmodule

