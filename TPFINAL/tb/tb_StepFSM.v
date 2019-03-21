`timescale 1ns / 1ps

`include "constants.vh"

module tb_StepFSM
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
)();

    reg clk;
    reg rst;
    reg start;
    reg rx_done;
    reg [UART_BITS - 1 : 0] rx_data;
    reg send_done;
    wire enable;
    wire send_start;
    wire [CLK_COUNTER_BITS - 1 : 0] clk_count;
    wire done;

    localparam HLT = 32'hffffffff;

    localparam OP_STEP = 4;
    localparam OP_STOP = 5;

    integer i;
    initial begin
        clk = 1;
        rst = 0;
        rx_done = 0;
        rx_data = 0;
        start = 0;
        send_done = 0;
        #100
        rst = 1;
        #20
        start = 1;
        #20
        start = 0;
        #20
        send_done = 1;
        #20 
        send_done = 0;
        #200
        
        //running 20 steps
        for(i = 0; i<20; i=i+1) begin
            rx_done = 1;
            rx_data = OP_STEP;
            #20
            rx_done = 0;
            #100
            send_done = 1;
            #20
            send_done = 0;
            #20;
        end

        //sending finish
        rx_done = 1;
        rx_data = OP_STOP;
        #20;
        rx_done = 0;
    end

    always #10 clk = ~clk;

    StepFSM step_fsm (
        .clk(clk),
        .rst(rst),
        .i_start(start),
        .i_rx_done(rx_done),
        .i_rx_data(rx_data),
        .i_send_done(send_done),
        .o_enable(enable),
        .o_send_start(send_start),
        .o_clk_count(clk_count),
        .o_done(done)
    );


endmodule
