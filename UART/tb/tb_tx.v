
module tb_tx();
    reg clk, rst, tx_start, baud_rate;
    wire tx_done, tx;
    reg [7:0] data;

    TX u_tx(
        .clk(clk),
        .rst(rst),
        .i_baud_rate(baud_rate),
        .i_tx_start(tx_start),
        .i_data(data),
        .o_tx_done(tx_done),
        .o_tx(tx)
    );

    initial begin
        clk = 0;
        rst = 0;
        baud_rate = 0;
        tx_start = 0;

        #2 rst = 1;
        #2 baud_rate = 1;
        #2 data = 8'b01110101;
        #2 tx_start = 1;
        #2 tx_start = 0;
        
    end

    always #1 clk = ~clk;

endmodule
