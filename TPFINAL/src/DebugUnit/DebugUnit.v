`timescale 1ns / 1ps

`include "constants.vh"

module DebugUnit
#(
    parameter UART_BITS = `UART_BITS,

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
    input clk,
    input rst,

    //uart inputs
    input wire i_rx,

    //inputs from datapath
    input wire [RF_REGS_LEN - 1 : 0] i_rf_regs,
    input wire [IF_ID_LEN - 1 : 0]   i_if_id_signals,
    input wire [ID_EX_LEN - 1 : 0]   i_id_ex_signals,
    input wire [EX_MEM_LEN - 1 : 0]  i_ex_mem_signals,
    input wire [MEM_WB_LEN - 1 : 0]  i_mem_wb_signals,
    input wire [PROC_BITS - 1 : 0]   i_mem_data,

    //output to datapath
    output reg                             o_enable,
    output wire                            o_write_inst_mem,
    output wire [PC_BITS - 1 : 0]          o_inst_mem_addr,
    output wire [INSTRUCTION_BITS - 1 : 0] o_inst_mem_data,
    output wire                            o_debug_read_data,
    output wire [DATA_ADDRS_BITS - 1 : 0]  o_debug_read_address,

    //uart output
    output wire o_tx

);

    //wires for connection between debugFSM and UART
    wire [UART_BITS - 1 : 0] rx_data;
    wire [UART_BITS - 1 : 0] tx_data;
    wire tx_start;
    wire tx_done;
    wire rx_done;

    DebugFSM debug_fsm(
        .clk(clk),
        .rst(rst),
        .i_rx_data(rx_data),
        .i_tx_done(tx_done),
        .i_rx_done(rx_done),
        .i_rf_regs(i_rf_regs),
        .i_if_id_signals(i_if_id_signals),
        .i_id_ex_signals(i_id_ex_signals),
        .i_ex_mem_signals(i_ex_mem_signals),
        .i_mem_wb_signals(i_mem_wb_signals),
        .i_mem_data(i_mem_data),
        .o_enable(o_enable),
        .o_write_inst_mem(o_write_inst_mem),
        .o_inst_mem_addr(o_inst_mem_addr),
        .o_inst_mem_data(o_inst_mem_data),
        .o_debug_read_data(o_debug_read_data),
        .o_debug_read_address(o_debug_read_address),
        .o_tx_start(tx_start),
        .o_tx_data(o_tx_data)
    );

    UART uart_u(
        .clk(clk),
        .rst(rst),
        .i_rx(i_rx),
        .i_tx_start(tx_start),
        .i_tx_data(tx_data),
        .o_tx(o_tx),
        .o_rx_data(rx_data),
        .o_tx_done(tx_done),
        .o_rx_done(rx_done)
    );

endmodule

