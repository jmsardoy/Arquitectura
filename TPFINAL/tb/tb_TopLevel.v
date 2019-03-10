`timescale 1ns / 1ps

`include "constants.vh"

module tb_TopLevel();


    reg clk;
    reg clk_50;
    reg rst;
    wire rst_c = ~rst;
    wire baud_rate;
    reg tx_start;
    reg [7:0] tx_data;
    wire tx_done;
    wire rx;
    wire tx;

    localparam OP_LOAD_INST = 1;
    localparam OP_RUN       = 2;
    localparam OP_RUN_STEP  = 3;
    localparam OP_STEP = 4;
    localparam OP_STOP = 5;

    integer i;

    initial begin
        clk = 1;
        rst = 0;
        #1000
        rst = 1;
        #4
        tx_data = OP_RUN_STEP;
        tx_start = 1;
        #4
        tx_start = 0;

        for(i = 0; i<15; i=i+1) begin
            #2000
            tx_data = OP_STEP;
            tx_start = 1;
            #4
            tx_start = 0;
        end

    end



    always #1 clk = ~clk;
    always@(posedge clk) begin
        if (!rst) begin
            clk_50 = 0;
        end
        else begin
            clk_50 = ~clk_50;
        end
    end

    TopLevel top_level_u(
        .clk(clk),
        .btnC(rst_c),
        .RsRx(rx),
        .RsTx(tx)
    );

    BaudRateGenerator br_g(
        .clk(clk_50),
        .rst(rst),
        .out(baud_rate)
    );

    TX tx_u(
        .clk(clk_50),
        .rst(rst),
        .i_baud_rate(baud_rate),
        .i_tx_start(tx_start),
        .i_data(tx_data),
        .o_tx_done(tx_done),
        .o_tx(rx)
    );

endmodule

