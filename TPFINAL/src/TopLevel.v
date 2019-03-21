`timescale 1ns / 1ps

`include "constants.vh"

module TopLevel
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
    input btnC,

    input RsRx,
    output RsTx,

    output [15:0] led,
    output [6:0] seg
);

    wire o_tx;
    wire i_rx;
    wire rst;
    assign i_rx = RsRx;
    assign RsTx = o_tx;
    assign rst = ~btnC;
    wire rx_done;

    wire [UART_BITS - 1 : 0] rx_data;


    //output from datapath, inputs to debug
    wire [RF_REGS_LEN - 1 : 0] rf_regs;
    wire [IF_ID_LEN - 1 : 0]   if_id_signals;
    wire [ID_EX_LEN - 1 : 0]   id_ex_signals;
    wire [EX_MEM_LEN - 1 : 0]  ex_mem_signals;
    wire [MEM_WB_LEN - 1 : 0]  mem_wb_signals;
    wire [PROC_BITS - 1 : 0]   mem_data;

    //outputs from debug, input to datapath
    wire                            enable_datapath;
    wire                            write_inst_mem;
    wire [PC_BITS - 1 : 0]          inst_mem_addr;
    wire [INSTRUCTION_BITS - 1 : 0] inst_mem_data;
    wire                            debug_read_data;
    wire [DATA_ADDRS_BITS - 1 : 0]  debug_read_address;
    wire                            rst_mips;

    //assign led[15:12] = send_state;
    //assign led[11:8] = 0;
    assign led[15:8] = inst_mem_data[7:0];
    assign led[UART_BITS - 1 : 0] = rx_data;

    wire [2:0] debug_state;

    Datapath datapath_u(
        .clk(clk),
        .rst(rst_mips),
        .enable(enable_datapath),
        .i_write_inst_mem(write_inst_mem),
        .i_inst_mem_addr(inst_mem_addr),
        .i_inst_mem_data(inst_mem_data),
        .i_debug_read_data(debug_read_data),
        .i_debug_read_address(debug_read_address),
        .o_if_id_signals(if_id_signals),
        .o_id_ex_signals(id_ex_signals),
        .o_ex_mem_signals(ex_mem_signals),
        .o_mem_wb_signals(mem_wb_signals),
        .o_rf_regs(rf_regs),
        .o_mem_data(mem_data)
    );
    
    DebugUnit debug_unit_u(
        .clk(clk),
        .rst(rst),
        .i_rx(i_rx),
        .i_rf_regs(rf_regs),
        .i_if_id_signals(if_id_signals),
        .i_id_ex_signals(id_ex_signals),
        .i_ex_mem_signals(ex_mem_signals),
        .i_mem_wb_signals(mem_wb_signals),
        .i_mem_data(mem_data),
        .o_enable(enable_datapath),
        .o_write_inst_mem(write_inst_mem),
        .o_inst_mem_addr(inst_mem_addr),
        .o_inst_mem_data(inst_mem_data),
        .o_debug_read_data(debug_read_data),
        .o_debug_read_address(debug_read_address),
        .o_rst_mips(rst_mips),
        .o_state(debug_state),
        .o_tx(o_tx),
        .o_rx_done(rx_done),
        .o_rx_data(rx_data)
    );

    SevenSegmentDecoder seg_decod_u(
        .i_debug_state(debug_state),
        .o_seg(seg)
    );

endmodule
