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
    wire write_inst_mem;
    wire [PC_BITS - 1 : 0] inst_mem_addr;
    wire [INSTRUCTION_BITS - 1 : 0] inst_mem_data;
    reg                           debug_read_data;
    reg [DATA_ADDRS_BITS - 1 : 0] debug_read_address;

    wire [IF_ID_LEN - 1 : 0]    if_id_signals;
    wire [ID_EX_LEN - 1 : 0]    id_ex_signals;
    wire [EX_MEM_LEN - 1 : 0]   ex_mem_signals;
    wire [RF_REGS_LEN - 1 : 0 ] rf_regs;
    wire [PROC_BITS - 1 : 0]    mem_data;


    reg [31:0] mem [0:31];

    reg load_fsm_start;
    reg rx_done;
    reg [7:0] rx_data;

    integer i;
    initial begin
        clk = 1;
        rst = 0;
        enable = 0;
        debug_read_data = 0;
        debug_read_address = 0;


        #40
        rst = 1;

        $readmemb("testasm.mem", mem);
        load_fsm_start = 1;
        #20
        load_fsm_start = 0;
        #20
        for(i=0;i<15; i=i+1) begin
            rx_data = mem[i][31 : 24];   
            rx_done = 1;
            #20
            rx_done = 0;
            #100
            rx_data = mem[i][23 : 16];   
            rx_done = 1;
            #20
            rx_done = 0;
            #100
            rx_data = mem[i][15 : 8];   
            rx_done = 1;
            #20
            rx_done = 0;
            #100
            rx_data = mem[i][ 7 : 0];   
            rx_done = 1;
            #20
            rx_done = 0;
            #100;
        end

        


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
        .o_rf_regs(rf_regs),
        .o_mem_data(mem_data)
    );

    LoadInstFSM load_fsm(
        .clk(clk),
        .rst(rst),
        .i_start(load_fsm_start),
        .i_rx_done(rx_done),
        .i_rx_data(rx_data),
        .o_write_inst_mem(write_inst_mem),
        .o_inst_mem_addr(inst_mem_addr),
        .o_inst_mem_data(inst_mem_data),
        .o_done(load_fsm_done)
    );

endmodule
