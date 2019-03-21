`timescale 1ns/1ps

`include "constants.vh"

module UART
#(
    parameter UART_BITS = `UART_BITS
)
(
    input wire clk,
    input wire rst,
    input wire i_rx,
    input wire i_tx_start,
    input wire [UART_BITS - 1 : 0] i_tx_data,

    output wire o_tx,
    output wire [UART_BITS - 1 : 0] o_rx_data,
    output wire o_tx_done,
    output wire o_rx_done

);

    wire baud_rate;

    BaudRateGenerator u_baud_rate(
        .clk(clk),
        .rst(rst),
        .out(baud_rate)
    );

    TX
    #(
        .NBITS(UART_BITS)
    )  u_tx(
        .clk(clk),
        .rst(rst),
        .i_baud_rate(baud_rate),
        .i_tx_start(i_tx_start),
        .i_data(i_tx_data),
        .o_tx_done(o_tx_done),
        .o_tx(o_tx)
    );

    RX 
    #(
        .NBITS(UART_BITS)
    ) u_rx(
        .clk(clk),
        .rst(rst),
        .i_baud_rate(baud_rate),
        .i_rx(i_rx),
        .o_rx_done(o_rx_done),
        .o_data(o_rx_data)
    );


endmodule
