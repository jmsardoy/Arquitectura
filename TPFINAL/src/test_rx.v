
module test_rx(input clk,
               input btnC, 
               input RsRx,
               output reg [15:0] led

);

wire rx = RsRx;
wire rst = ~btnC;

wire baud_rate;
wire rx_done;
wire [7:0] rx_data;

always@(posedge clk) begin
    led[15:8] <= 0;
    if (!rst) begin
        led[7:0] <= 1;
    end
    else begin
        if (rx_done) begin
            led[7:0] <= rx_data;
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
