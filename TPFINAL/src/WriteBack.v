`timescale 1ns / 1ps

`include "constants.vh"

module WriteBack
#(
    parameter PC_BITS         = `PC_BITS,
    parameter PROC_BITS       = `PROC_BITS,
    parameter REG_ADDRS_BITS  = `REG_ADDRS_BITS
)
(
    input wire [PROC_BITS - 1 : 0]     i_alu_data,
    input wire [PROC_BITS - 1 : 0]     i_mem_data,
    input wire [PC_BITS - 1 : 0]       i_pc_return,
    input wire i_MemtoReg,
    input wire i_pc_to_reg,

    output wire [PROC_BITS - 1 : 0] o_reg_data
);

    wire [PROC_BITS - 1 : 0] data_aux;

    //assumes that PC_BITS == PROC_BITS
    assign data_aux = (i_MemtoReg)    ? i_mem_data : i_alu_data;
    assign o_reg_data = (i_pc_to_reg) ? i_pc_return : data_aux;

endmodule
