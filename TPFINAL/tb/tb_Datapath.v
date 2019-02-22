`timescale 1ns / 1ps

`include "constants.vh"

module tb_Datapath();

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
    reg enable;
    reg write_inst_mem;
    reg [PC_BITS - 1 : 0] inst_mem_addr;
    reg [INSTRUCTION_BITS - 1 : 0] inst_mem_data;
    reg                           debug_read_data;
    reg [DATA_ADDRS_BITS - 1 : 0] debug_read_address;

    wire [IF_ID_LEN - 1 : 0]    if_id_signals;
    wire [ID_EX_LEN - 1 : 0]    id_ex_signals;
    wire [EX_MEM_LEN - 1 : 0]   ex_mem_signals;
    wire [RF_REGS_LEN - 1 : 0 ] rf_regs;

    initial begin
        clk = 1;
        rst = 0;
        enable = 1;
        write_inst_mem = 0;
        inst_mem_addr = 0;
        inst_mem_data = 0;
        debug_read_data = 0;
        debug_read_address = 0;


        #40
        rst = 1;

    end

    always #10 clk = ~clk;

    Datapath datapath_u(
        .clk(clk),
        .rst(rst),
        .enable(enable),
        .i_write_inst_mem(write_inst_mem),
        .i_inst_mem_addr(inst_mem_addr),
        .i_inst_mem_data(inst_mem_data),
        .i_debug_read_data(debug_read_data),
        .i_debug_read_address(debug_read_address),
        .o_if_id_signals(if_id_signals),
        .o_id_ex_signals(id_ex_signals),
        .o_ex_mem_signals(ex_mem_signals),
        .o_rf_regs(rf_regs)
    );

endmodule
