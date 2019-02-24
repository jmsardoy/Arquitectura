`timescale 1ns / 1ps

`include "constants.vh"

module DebugFSM
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

    //inputs from uart
    wire [UART_BITS - 1 : 0] i_rx_data,
    wire i_tx_done,
    wire i_rx_done,

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

    //outputs to uart
    output wire o_tx_start,
    output wire [UART_BITS - 1 : 0] o_tx_data


);

    localparam IDLE       = 0;
    localparam START_LOAD = 1;
    localparam WAIT_LOAD  = 2;
    localparam START_RUN  = 3;
    localparam WAIT_RUN   = 4;
    localparam START_STEP = 5;
    localparam WAIT_STEP  = 6;

    localparam OP_LOAD_INST = 1;
    localparam OP_RUN       = 2;
    localparam OP_RUN_STEP  = 3;


    reg [2:0] state;
    reg [2:0] next_state;


    //reg for fsm starts signals
    reg load_fsm_start;
    reg run_fsm_start;
    reg step_fsm_start;

    //wires for fsm done signals
    wire load_fsm_done;
    wire run_fsm_done;
    wire step_fsm_done;

    //wires for fsm's enables signals
    wire run_fsm_enable;
    wire step_fsm_enable;

    //wires for connection between run and stem fsm's and SendData fsm
    wire run_fsm_send_start;
    wire step_fsm_send_start;
    wire [CLK_COUNTER_BITS - 1 : 0] run_fsm_clk_count;
    wire [CLK_COUNTER_BITS - 1 : 0] step_fsm_clk_count;

    reg [CLK_COUNTER_BITS - 1 : 0] clk_count;
    reg send_start;
    wire send_done;

    //wires for run and step fsm's
    wire                            run_read_data;
    wire [DATA_ADDRS_BITS - 1 : 0]  run_read_address;
    wire                            step_read_data;
    wire [DATA_ADDRS_BITS - 1 : 0]  step_read_address;


    //wire for extracting instruction from i_if_id_signals;
    wire [INSTRUCTION_BITS - 1 : 0] instruction;
    assign instruction = i_if_id_signals[INSTRUCTION_BITS - 1 : 0];

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
                    if (i_rx_done) begin
                        case(i_rx_data)
                            OP_LOAD_INST: next_state = START_LOAD;
                            OP_RUN:       next_state = START_RUN;
                            OP_RUN_STEP:  next_state = START_STEP;
                            default:      next_state = IDLE;
                        endcase
                    end
                    else begin
                        next_state = IDLE;
                    end
                end
                START_LOAD: begin
                    next_state = WAIT_LOAD;
                end
                WAIT_LOAD: begin
                    if (load_fsm_done) next_state = IDLE;
                    else               next_state = WAIT_LOAD;
                end
                START_RUN: begin
                    next_state = WAIT_RUN;
                end
                WAIT_RUN: begin
                    if (run_fsm_done) next_state = IDLE;
                    else              next_state = WAIT_RUN;
                    
                end
                START_STEP: begin
                    next_state = WAIT_STEP;
                end
                WAIT_STEP: begin
                    if (step_fsm_done) next_state = IDLE;
                    else               next_state = WAIT_STEP;
                    
                end
            endcase
        end
    end

    //output logic
    always@* begin
        case (state)
            IDLE: begin
                o_enable       = 0;
                load_fsm_start = 0;
                run_fsm_start  = 0;
                step_fsm_start = 0;
                clk_count      = 0;
                send_start     = 0;
            end
            START_LOAD: begin
                o_enable       = 0;
                load_fsm_start = 1;
                run_fsm_start  = 0;
                step_fsm_start = 0;
                clk_count      = 0;
                send_start     = 0;
            end
            WAIT_LOAD: begin
                o_enable       = 0;
                load_fsm_start = 0;
                run_fsm_start  = 0;
                step_fsm_start = 0;
                clk_count      = 0;
                send_start     = 0;
            end
            START_RUN: begin
                o_enable       = 0;
                load_fsm_start = 0;
                run_fsm_start  = 1;
                step_fsm_start = 0;
                clk_count      = 0;
                send_start     = 0;
            end
            WAIT_RUN: begin
                o_enable       = run_fsm_enable;
                load_fsm_start = 0;
                run_fsm_start  = 0;
                step_fsm_start = 0;
                clk_count      = run_fsm_clk_count;
                send_start     = run_fsm_send_start;
            end
            START_STEP: begin
                o_enable       = 0;
                load_fsm_start = 0;
                run_fsm_start  = 0;
                step_fsm_start = 1;
                clk_count      = 0;
                send_start     = 0;
            end
            WAIT_RUN: begin
                o_enable       = step_fsm_enable;
                load_fsm_start = 0;
                run_fsm_start  = 0;
                step_fsm_start = 0;
                clk_count      = step_fsm_clk_count;
                send_start     = step_fsm_send_start;
            end
            default: begin
                o_enable       = 0;
                load_fsm_start = 0;
                run_fsm_start  = 0;
                step_fsm_start = 0;
                clk_count      = 0;
                send_start     = 0;
            end
        endcase
    end


    LoadInstFSM load_fsm(
        .clk(clk),
        .rst(rst),
        .i_start(load_fsm_start),
        .i_rx_done(i_rx_done),
        .i_rx_data(i_rx_data),
        .o_write_inst_mem(o_write_inst_mem),
        .o_inst_mem_addr(o_inst_mem_addr),
        .o_inst_mem_data(o_inst_mem_data),
        .o_done(load_fsm_done)
    );

    RunFSM run_fsm (
        .clk(clk),
        .rst(rst),
        .i_start(run_fsm_start),
        .i_send_done(send_done),
        .i_instruction(instruction),
        .o_enable(run_fsm_enable),
        .o_send_start(run_fsm_send_start),
        .o_clk_count(run_fsm_clk_count),
        .o_done(run_fsm_done)
    );

    SendDataFSM send_data_fsm(
        .clk(clk),
        .rst(rst),
        .i_start(send_start),
        .i_tx_done(i_tx_done),
        .i_rf_regs(i_rf_regs),
        .i_if_id_signals(i_if_id_signals),
        .i_id_ex_signals(i_id_ex_signals),
        .i_ex_mem_signals(i_ex_mem_signals),
        .i_mem_wb_signals(i_mem_wb_signals),
        .i_mem_data(i_mem_data),
        .i_clk_count(clk_count),
        .o_debug_read_data(o_debug_read_data),
        .o_debug_read_address(o_debug_read_address),
        .o_tx_start(o_tx_start),
        .o_tx_data(o_tx_data),
        .o_done(send_done)
    );

    /*
    StepFSM step_fsm (
        .clk(clk),
        .rst(rst),
        .i_start(step_fsm_start),
        .i_send_done(send_done),
        .i_instruction(instruction),
        .o_enable(step_fsm_enable),
        .o_send_start(step_fsm_send_start),
        .o_clk_count(step_fsm_clk_count),
        .o_done(step_fsm_done)
    );
    */
    


endmodule

