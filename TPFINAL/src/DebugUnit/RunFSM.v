`timescale 1ns / 1ps

`include "constants.vh"

module RunFSM
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
    input i_send_done,
    //instruction is needed to check for halt
    input [PROC_BITS - 1 : 0] i_instruction,

    //output to datapath
    output reg o_enable,

    //output to SendDataFSM
    output reg o_send_start,
    output reg [CLK_COUNTER_BITS - 1 : 0] o_clk_count,

    output reg o_done
    
);

    localparam HLT = 32'hffffffff;

    localparam IDLE      = 0;
    localparam RUNNING   = 1;
    localparam CHECK_HLT = 2;
    localparam SEND_DATA = 3;
    localparam WAIT_SEND = 4;
    localparam FINISH    = 5;

    reg [2:0] state;
    reg [2:0] next_state;

    reg [1:0] halt_counter;

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
                    if (i_start) next_state = RUNNING;
                    else         next_state = IDLE;
                end
                RUNNING: begin
                    if (i_instruction == HLT) next_state = CHECK_HLT;
                    else                      next_state = RUNNING;
                end
                CHECK_HLT: begin
                    if (i_instruction == HLT) begin
                        if (halt_counter == 2) next_state = SEND_DATA;
                        else                   next_state = CHECK_HLT;
                    end
                    else next_state = RUNNING;
                end
                SEND_DATA: begin
                    next_state = WAIT_SEND;
                end
                WAIT_SEND: begin
                    if (i_send_done) next_state = FINISH;
                    else             next_state = WAIT_SEND;
                end
                FINISH: begin
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
            RUNNING: begin
                o_enable     = 1;
                o_send_start = 0;
                o_done       = 0;
            end
            CHECK_HLT: begin
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
            halt_counter <= 0;
            o_clk_count <= 0;
        end
        else begin
            case (state)
                IDLE: begin
                    halt_counter <= 0;
                    o_clk_count <= 0;
                end
                RUNNING: begin
                    if (i_instruction == HLT) begin
                        halt_counter <= halt_counter + 1;
                    end
                    o_clk_count <= o_clk_count + 1;
                end
                CHECK_HLT: begin
                    if (i_instruction == HLT) begin
                        halt_counter <= halt_counter + 1;
                    end
                    o_clk_count <= o_clk_count + 1;
                end
            endcase
        end
    end


endmodule
