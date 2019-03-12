`timescale 1ns / 1ps

`include "constants.vh"

module MemoryStage
#(
    parameter PC_BITS         = `PC_BITS,
    parameter PROC_BITS       = `PROC_BITS,
    parameter REG_ADDRS_BITS  = `REG_ADDRS_BITS,
    parameter DATA_ADDRS_BITS = `DATA_ADDRS_BITS
)
(
    input wire clk,
    input wire enable,

    input wire [PROC_BITS - 1 : 0]      i_alu_data,
    input wire [PROC_BITS - 1 : 0]      i_store_data,
    input wire [REG_ADDRS_BITS - 1 : 0] i_rd,

    //inputs from branch unit
    input wire i_pc_to_reg,
    input wire [PC_BITS - 1 : 0] i_pc_return,

    //inputs from control
    input wire i_RegWrite,
    input wire i_MemRead, //unconneted cause BRAM doesnt' support read_enable
    input wire i_MemWrite,
    input wire i_MemtoReg,
    input wire [2:0] i_ls_filter_op,

    input i_debug_read_data,
    input [DATA_ADDRS_BITS - 1 : 0] i_debug_read_address,


    output wire [PROC_BITS - 1 : 0]      o_alu_data,
    output wire [PROC_BITS - 1 : 0]      o_mem_data,
    output wire [REG_ADDRS_BITS - 1 : 0] o_rd,

    //outputs from branch unit
    output wire o_pc_to_reg,
    output wire [PC_BITS - 1 : 0] o_pc_return,

    //output from control
    output wire o_RegWrite,
    output wire o_MemtoReg
);

    //muxs for read from debug
    wire [DATA_ADDRS_BITS - 1 : 0] mem_address;
    //assign mem_address = (i_debug_read_data) ? i_debug_read_address :
    //                                           i_alu_data[DATA_ADDRS_BITS - 1 : 0];
    assign mem_address = (enable) ? i_alu_data[DATA_ADDRS_BITS - 1 : 0] : i_debug_read_address;
    //disable write while reading from debug
    wire mem_write_enable;
    //assign mem_write_enable = (i_debug_read_data) ? 0 : i_MemWrite;
    assign mem_write_enable = (enable) ?  i_MemWrite : 0;

    wire [2:0] load_filter_op;
    assign load_filter_op = (enable) ? i_ls_filter_op : 3'b011;

    //wires for Filter and BRAM connections
    wire [PROC_BITS - 1 : 0] mem_data_raw;
    wire [PROC_BITS - 1 : 0] store_data_filtered;

    //directs assigns
    assign o_alu_data = i_alu_data;
    assign o_rd = i_rd;

    //Control and Branch directs assigns
    assign o_RegWrite = i_RegWrite;
    assign o_MemtoReg = i_MemtoReg;
    assign o_pc_to_reg = i_pc_to_reg;
    assign o_pc_return = i_pc_return;


    LoadFilter load_filter_u(
        .i_data_in(mem_data_raw),
        .i_ls_filter_op(load_filter_op),
        .o_data_out(o_mem_data)
    );

    StoreFilter store_filter_u(
        .i_data_in(i_store_data),
        .i_ls_filter_op(i_ls_filter_op),
        .o_data_out(store_data_filtered)
    );

    BRAM  #(
        .ADDRESS_BITS(DATA_ADDRS_BITS),
        .DATA_BITS(PROC_BITS)
    ) data_memory (
        .clk(clk),
        .write_enable(mem_write_enable),
        .i_address(mem_address),
        .i_data(store_data_filtered),
        .o_data(mem_data_raw)
    );

endmodule
