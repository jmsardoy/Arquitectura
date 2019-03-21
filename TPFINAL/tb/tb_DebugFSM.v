`timescale 1ns / 1ps

`include "constants.vh"

module tb_DebugFSM
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

    //inputs from uart
    reg [UART_BITS - 1 : 0] rx_data;
    reg tx_done;
    reg rx_done;


    //inputs from datapath
    reg [RF_REGS_LEN - 1 : 0] i_rf_regs;
    reg [IF_ID_LEN - 1 : 0]   i_if_id_signals;
    reg [ID_EX_LEN - 1 : 0]   i_id_ex_signals;
    reg [EX_MEM_LEN - 1 : 0]  i_ex_mem_signals;
    reg [MEM_WB_LEN- 1 : 0]  i_mem_wb_signals;
    reg [PROC_BITS - 1 : 0]   i_mem_data;

    //output to datapath
    wire                            o_enable;
    wire                            o_write_inst_mem;
    wire [PC_BITS - 1 : 0]          o_inst_mem_addr;
    wire [INSTRUCTION_BITS - 1 : 0] o_inst_mem_data;
    wire                            o_debug_read_data;
    wire [DATA_ADDRS_BITS - 1 : 0]  o_debug_read_address;


    //outputs to uart
    wire tx_start;
    wire [UART_BITS - 1 : 0] tx_data;

    integer i;

    initial begin
        clk = 1;
        rst = 0;
        rx_done = 0;
        tx_done = 1;
        i_rf_regs <= 0;
        i_if_id_signals <= 0;
        i_id_ex_signals <= 0;
        i_ex_mem_signals <= 0;
        i_mem_wb_signals <= 0;
        i_mem_data <= 0;

        #100
        rst = 1;
        #100

        //testing instruction load
        rx_done = 1;
        rx_data = 1;
        #20
        rx_done = 0;
        //testings inst_count == 0
        #20 
        rx_data = 0;
        rx_done = 1;
        #20
        rx_done = 0;

        //testings inst_count == 4
        #20 
        rx_data = 4;
        rx_done = 1;
        #20
        rx_done = 0;

        #20

        //loading 4 instructions
        for(i=0; i<4*4; i= i+1) begin
            rx_data = i;
            rx_done = 1;
            #20
            rx_done = 0;
            #60;
        end

        //testing run fsm
        rx_done = 1;
        rx_data = 2;
        #20
        rx_done = 0;

        #100
        i_if_id_signals = -1;
        

            
        


    ;
    end

    always #10 clk = ~clk;

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
        .o_tx_data(tx_data)
    );


endmodule

