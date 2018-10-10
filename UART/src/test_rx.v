
module test_rx(input CLK100MHZ,
               input rst, 
               input uart_txd_in,
               output reg [3:0] o_led

);

wire clk = CLK100MHZ;
wire rx = uart_txd_in;

wire baud_rate;
wire rx_done;
wire [7:0] rx_data;

always@(posedge clk) begin
    if (!rst) begin
        o_led <= 4'b0101;
    end
    else begin
        if (rx_done) begin
            o_led <= rx_data[3:0];
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
endmodule
