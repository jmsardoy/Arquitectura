
module test_echo(input CLK100MHZ,
               input rst, 
               input uart_txd_in,
               output uart_rxd_out
);

wire clk = CLK100MHZ;
wire rx = uart_txd_in;
wire tx;
assign uart_rxd_out = tx;

wire baud_rate;
wire rx_done;
wire [7:0] rx_data;

reg tx_start;
reg [7:0] tx_data;
wire tx_done;


always@(posedge clk) begin
    if (!rst) begin
        tx_start <= 0;
        tx_data <= 0;
    end
    else begin
        if(rx_done) begin
            tx_data <= rx_data;
            tx_start <= 1;
        end
        else begin
            tx_start <= 0;
        end
    end
end


BaudRateGenerator u_baud_rate(
    .clk(clk),
    .rst(rst),
    .out(baud_rate)
);

RX u_rx(
    .clk(clk),
    .rst(rst),
    .i_baud_rate(baud_rate),
    .i_rx(rx),
    .o_rx_done(rx_done),
    .o_data(rx_data)
);

TX u_tx(
    .clk(clk),
    .rst(rst),
    .i_baud_rate(baud_rate),
    .i_tx_start(tx_start),
    .i_data(tx_data),
    .o_tx_done(tx_done),
    .o_tx(tx)
);
endmodule
