`timescale 1ns / 1ps

`include "constants.vh"

module tb_RunFSM
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
    reg send_done;
    reg [INSTRUCTION_BITS - 1 : 0] instruction;
    wire enable;
    wire send_start;
    wire [CLK_COUNTER_BITS - 1 : 0] clk_count;
    wire done;

    localparam HLT = 32'hffffffff;

    initial begin
        clk = 1;
        rst = 0;
        start = 0;
        send_done = 0;
        instruction = 0;
        #100
        rst = 1;
        #20
        start = 1;
        #20
        start = 0;
        #100
        instruction = HLT;

        #100
        send_done = 1;
        #20
        send_done = 0;


    end

    always #10 clk = ~clk;

    RunFSM run_fsm (
        .clk(clk),
        .rst(rst),
        .i_start(start),
        .i_send_done(send_done),
        .i_instruction(instruction),
        .o_enable(enable),
        .o_send_start(send_start),
        .o_clk_count(clk_count),
        .o_done(done)
    );


endmodule
