`timescale 1ns / 1ps

`include "constants.vh"

module tb_SendDataFSM();

    localparam UART_BITS = `UART_BITS;

    localparam PC_BITS          = `PC_BITS;
    localparam INSTRUCTION_BITS = `INSTRUCTION_BITS;
    localparam PROC_BITS        = `PROC_BITS;
    localparam REG_ADDRS_BITS   = `REG_ADDRS_BITS;
    localparam OPCODE_BITS      = `OPCODE_BITS;
    localparam DATA_ADDRS_BITS  = `DATA_ADDRS_BITS;

    localparam IF_ID_LEN  = `IF_ID_LEN;
    localparam ID_EX_LEN  = `ID_EX_LEN;
    localparam EX_MEM_LEN = `EX_MEM_LEN;
    localparam MEM_WB_LEN = `MEM_WB_LEN;
    localparam RF_REGS_LEN = `RF_REGS_LEN;


    
    reg clk;
    reg rst;
    reg start;
    reg tx_done;

    reg [RF_REGS_LEN - 1 : 0] rf_regs;
    reg [IF_ID_LEN - 1 : 0]   if_id_signals;
    reg [ID_EX_LEN - 1 : 0]   id_ex_signals;
    reg [EX_MEM_LEN - 1 : 0]  ex_mem_signals;
    reg [MEM_WB_LEN - 1 : 0]  mem_wb_signals;
    reg [PROC_BITS - 1 : 0]   mem_data;
    reg [7 : 0]               clk_count;

    wire                            debug_read_data;
    wire [DATA_ADDRS_BITS - 1 : 0]  debug_read_address;

    wire tx_start;
    wire [UART_BITS - 1 : 0] tx_data;

    wire done;

    initial begin
        clk = 1;
        rst = 0;
        start = 0;
        tx_done = 1;
        clk_count = 156;
        rf_regs[RF_REGS_LEN -1 -: UART_BITS] = 5;
        rf_regs[RF_REGS_LEN -UART_BITS - 1 -: UART_BITS] = 8;
        #20
        rst = 1;
        #100

        start = 1;
        #20
        start = 0;
    end
    always@(negedge clk) begin
        if (debug_read_data) begin
            mem_data <= debug_read_address+1;
        end
    end

    always #10 clk = ~clk;

    SendDataFSM send_data_fsm(
        .clk(clk),
        .rst(rst),
        .i_start(start),
        .i_tx_done(tx_done),
        .i_rf_regs(rf_regs),
        .i_if_id_signals(if_id_signals),
        .i_id_ex_signals(id_ex_signals),
        .i_ex_mem_signals(ex_mem_signals),
        .i_mem_wb_signals(mem_wb_signals),
        .i_mem_data(mem_data),
        .i_clk_count(clk_count),
        .o_debug_read_data(debug_read_data),
        .o_debug_read_address(debug_read_address),
        .o_tx_start(tx_start),
        .o_tx_data(tx_data),
        .o_done(done)
    );

endmodule
