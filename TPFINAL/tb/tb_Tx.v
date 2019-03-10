`define NBITS 8

module tb_TX
#(
    parameter NBITS = `NBITS
)
();

    reg clk;
    reg rst;
    wire baud_rate;

    reg tx_start;
    reg [NBITS - 1 : 0] tx_data;
    wire tx_done;
    wire tx;
    wire rx_done;
    wire [NBITS - 1 : 0] rx_data;


    initial begin
        clk = 1;
        rst = 0;
        tx_start = 0;
        tx_data = 0;
        #100
        rst = 1;
        #100
        tx_data = 151;
        tx_start = 1;
        #20;
        tx_start = 0;
    end

    always #10 clk = ~clk;
    
    BaudRateGenerator brg_u(
        .clk(clk),
        .rst(rst),
        .out(baud_rate)
    );

    TX tx_u(
        .clk(clk),
        .rst(rst),
        .i_baud_rate(baud_rate),
        .i_tx_start(tx_start),
        .i_data(tx_data),
        .o_tx_done(tx_done),
        .o_tx(tx)
    );

    RX rx_u(
        .clk(clk),
        .rst(rst),
        .i_baud_rate(baud_rate),
        .i_rx(tx),
        .o_rx_done(rx_done),
        .o_data(rx_data)
    );


endmodule

