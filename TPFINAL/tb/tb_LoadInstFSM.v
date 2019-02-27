`timescale 1ns / 1ps

`include "constants.vh"

module tb_LoadInstFSM();

    localparam UART_BITS = `UART_BITS;
    localparam INST_ADDRS_BITS   = `INST_ADDRS_BITS;
    localparam INSTRUCTION_BITS = `INSTRUCTION_BITS;


    reg clk;
    reg rst;
    reg start;
    reg rx_done;
    reg [UART_BITS - 1 : 0] rx_data;


    wire                            write_inst_mem;
    wire [INST_ADDRS_BITS - 1 : 0]  inst_mem_addr;
    wire [INSTRUCTION_BITS - 1 : 0] inst_mem_data;
    wire                            done;

    integer i;

    initial begin
        clk = 1;
        rst = 0;
        start = 0;
        rx_done = 0;
        rx_data = 0;
        #20;
        rst = 1;
        #20;

        //send start to fsm
        start = 1;
        #20
        start = 0;
        #60

        //3 instructions will be loaded
        rx_data = 3;
        rx_done = 1;
        #20
        rx_done = 0;

        #20

        //loading 3 instructions
        for(i=0; i<4*3; i= i+1) begin
            rx_data = i;
            rx_done = 1;
            #20
            rx_done = 0;
            #100;
        end

    ;
    end


    always #10 clk = ~clk;
    
    LoadInstFSM load_inst_fsm(
        .clk(clk),
        .rst(rst),
        .i_start(start),
        .i_rx_done(rx_done),
        .i_rx_data(rx_data),
        .o_write_inst_mem(write_inst_mem),
        .o_inst_mem_addr(inst_mem_addr),
        .o_inst_mem_data(inst_mem_data),
        .o_done(done)
    );


endmodule
