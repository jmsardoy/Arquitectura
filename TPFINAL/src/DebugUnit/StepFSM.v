`timescale 1ns / 1ps

`include "constants.vh"

module StepFSM
#(
    parameter UART_BITS = `UART_BITS,

    parameter PC_BITS          = `PC_BITS,
    parameter INSTRUCTION_BITS = `INSTRUCTION_BITS,
    parameter PROC_BITS        = `PROC_BITS,
    parameter REG_ADDRS_BITS   = `REG_ADDRS_BITS,
    parameter OPCODE_BITS      = `OPCODE_BITS,
    parameter DATA_ADDRS_BITS  = `DATA_ADDRS_BITS,


    parameter CLK_COUNTER_BITS = `CLK_COUNTER_BITS,
    parameter IF_ID_LEN  = `IF_ID_LEN,
    parameter ID_EX_LEN  = `ID_EX_LEN,
    parameter EX_MEM_LEN = `EX_MEM_LEN,
    parameter MEM_WB_LEN = `MEM_WB_LEN,
    parameter RF_REGS_LEN = `RF_REGS_LEN
)
(
    input clk,
    input rst,

    input i_start,
    input i_rx_done,
    input [UART_BITS - 1 : 0] i_rx_data,
    input i_send_done,

    //output to datapath
    output reg o_enable,

    //output to SendDataFSM
    output reg o_send_start,
    output reg [CLK_COUNTER_BITS - 1 : 0] o_clk_count,

    output reg o_done
);

    localparam OP_STEP = 4;
    localparam OP_STOP = 5;

    localparam IDLE            = 0;
    localparam FIRST_SEND      = 1;
    localparam WAIT_FIRST_SEND = 2;
    localparam WAIT_STEP       = 3;
    localparam ENABLE          = 4;
    localparam SEND_DATA       = 5;
    localparam WAIT_SEND       = 6;
    localparam FINISH          = 7;

    reg [2:0] state;
    reg [2:0] next_state;

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
                    if (i_start) next_state = FIRST_SEND;
                    else         next_state = IDLE;
                end
                FIRST_SEND: begin
                    next_state = WAIT_FIRST_SEND;
                end
                WAIT_FIRST_SEND: begin
                    if (i_send_done) next_state = WAIT_STEP;
                    else             next_state = WAIT_FIRST_SEND;
                end
                WAIT_STEP: begin
                    if (i_rx_done) begin
                       if      (i_rx_data == OP_STEP) next_state = ENABLE; 
                       else if (i_rx_data == OP_STOP) next_state = FINISH;
                       else                           next_state = WAIT_STEP;
                    end
                    else begin
                        next_state = WAIT_STEP;
                    end
                end
                ENABLE: begin
                    next_state = SEND_DATA;
                end
                SEND_DATA: begin
                    next_state = WAIT_SEND;
                end
                WAIT_SEND: begin
                    if (i_send_done) next_state = WAIT_STEP;
                    else             next_state = WAIT_SEND;
                end
                FINISH: begin
                    next_state = IDLE;
                end
                default: begin
                    next_state = IDLE;
                end
            endcase
        end
    end


    //output logic
    always@* begin
        case (state)
            IDLE: begin
                o_enable     = 0;
                o_send_start = 0;
                o_done       = 0;
            end
            FIRST_SEND: begin
                o_enable     = 0;
                o_send_start = 1;
                o_done       = 0;
            end
            WAIT_FIRST_SEND: begin
                o_enable     = 0;
                o_send_start = 0;
                o_done       = 0;
            end
            WAIT_STEP: begin
                o_enable     = 0;
                o_send_start = 0;
                o_done       = 0;
            end
            ENABLE: begin
                o_enable     = 1;
                o_send_start = 0;
                o_done       = 0;
            end
            SEND_DATA: begin
                o_enable     = 0;
                o_send_start = 1;
                o_done       = 0;
            end
            WAIT_SEND: begin
                o_enable     = 0;
                o_send_start = 0;
                o_done       = 0;
            end
            FINISH: begin
                o_enable     = 0;
                o_send_start = 0;
                o_done       = 1;
            end
            default: begin
                o_enable     = 0;
                o_send_start = 0;
                o_done       = 0;
            end
        endcase
    end

    

    //inner logic
    always@(posedge clk) begin
        if (!rst) begin
            o_clk_count <= 0;
        end
        else begin
            case (state)
                IDLE: begin
                    o_clk_count <= 0;
                end
                ENABLE: begin
                    o_clk_count <= o_clk_count + 1;
                end
            endcase
        end
    end


endmodule
