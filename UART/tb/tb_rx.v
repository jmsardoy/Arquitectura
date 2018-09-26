
module tb_rx();
    reg clk, rst, rx, baud_rate;
    wire rx_done;
    wire [7:0] data;

    RX u_rx(
        .clk(clk),
        .rst(rst),
        .i_baud_rate(baud_rate),
        .i_rx(rx),
        .o_rx_done(rx_done),
        .o_data(data)
    );

    initial begin
        clk = 0;
        rst = 0;
        baud_rate = 0;
        rx = 1;

        #2 rst = 1;
        #2 baud_rate = 1;

        #2 rx = 0;
        #32 rx = 1;
        #32 rx = 0;
        #32 rx = 1;
        #32 rx = 1;
        #32 rx = 1;
        #32 rx = 1;
        #32 rx = 1;
        #32 rx = 1;
        #32 rx = 1;

        #100 rx = 0;
        #32 rx = 1;
        #32 rx = 1;
        #32 rx = 1;
        #32 rx = 1;
        #32 rx = 0;
        #32 rx = 1;
        #32 rx = 0;
        #32 rx = 1;
        #32 rx = 1;

    end

    always #1 clk = ~clk;

endmodule
