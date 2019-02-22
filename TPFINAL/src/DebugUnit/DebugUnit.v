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

    //uart input
    input i_rx,

    //inputs from datapath
    input wire [RF_REGS_LEN - 1 : 0] i_rf_regs,
    input wire [IF_ID_LEN - 1 : 0]   i_if_id_signals,
    input wire [ID_EX_LEN - 1 : 0]   i_id_ex_signals,
    input wire [EX_MEM_LEN - 1 : 0]  i_ex_mem_signals,
    input wire [MEM_WB_LEN - 1 : 0]  i_mem_wb_signals,
    input wire [PROC_BITS - 1 : 0]   i_mem_data,

    //output to datapath
    output wire                            o_enable,
    output wire                            o_write_inst_mem,
    output wire [PC_BITS - 1 : 0]          o_inst_mem_addr,
    output wire [INSTRUCTION_BITS - 1 : 0] o_inst_mem_data,
    output wire                            o_debug_read_data,
    output wire [DATA_ADDRS_BITS - 1 : 0]  o_debug_read_address,

    //uart output
    output o_tx


);
    
    //uart inputs
    wire tx_start;
    wire [UART_BITS - 1 : 0] tx_data;

    //uart outputs
    wire [UART_BITS - 1 : 0] rx_data;
    wire tx_done;
    wire rx_done;


    localparam IDLE = 0;
    localparam LOAD = 1;
    localparam RUN  = 2;
    localparam STEP = 3;

    localparam OP_LOAD_INST = 1;
    localparam OP_RUN       = 2;
    localparam OP_RUN_STEP  = 3;


    reg [1:0] state;
    reg [1:0] next_state;


    always@(posedge clk) begin
        if (!rst) begin
            state <= IDLE;
        end
        else begin
            state <= next_state;
        end
    end

    //state change logic
    always@* begin
        if (!rst) begin
            next_state = IDLE;
        end
        else begin
            case(state)
                IDLE: begin
                    if (rx_done) begin
                        case(rx_data)
                            OP_LOAD_INST: next_state = LOAD;
                            OP_RUN:       next_state = RUN;
                            OP_RUN_STEP:  next_state = STEP;
                            default:      next_state = IDLE;
                        endcase
                    end
                    else begin
                        next_state = IDLE;
                    end
                end
            endcase
        end
    end

    LoadInstFSM load_fsm(
        .clk(clk),
        .rst(rst),
        .i_start(start),
        .i_rx_done(rx_done),
        .i_rx_data(rx_data),
        .o_write_inst_mem(o_write_inst_mem),
        .o_inst_mem_addr(o_inst_mem_addr),
        .o_inst_mem_data(o_inst_mem_data),
        .o_done(load_fsm_done)
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

