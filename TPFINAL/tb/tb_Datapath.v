`timescale 1ns / 1ps

`include "constants.vh"

module tb_Datapath();

    localparam PC_BITS          = `PC_BITS;
    localparam INSTRUCTION_BITS = `INSTRUCTION_BITS;
    localparam PROC_BITS        = `PROC_BITS;
    localparam REG_ADDRS_BITS   = `REG_ADDRS_BITS;
    localparam OPCODE_BITS      = `OPCODE_BITS;

    reg clk;
    reg rst;
    reg enable;
    reg write_inst_mem;
    reg [PC_BITS - 1 : 0] inst_mem_addr;
    reg [INSTRUCTION_BITS - 1 : 0] inst_mem_data;
    wire [32*32-1 : 0 ] rf_regs;

    initial begin
        clk = 1;
        rst = 0;
        enable = 1;
        write_inst_mem = 0;
        inst_mem_addr = 0;
        inst_mem_data = 0;

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
        .o_rf_regs(rf_regs)
    );

endmodule
