
module test_tx(input CLK100MHZ,
               input rst, 
               input [3:0] i_sw,
               input [3:0] i_btn,
               output uart_rxd_out
);

wire clk = CLK100MHZ;
wire tx;
assign uart_rxd_out = tx;

wire baud_rate;
reg tx_start;
wire tx_done;
reg [7:0] tx_data;
reg [7:0] counter;
reg btn;

always@(posedge clk) begin
    if (!rst) begin
        tx_data <= 0;
        tx_start <= 0;
        counter <= 0;
        btn <= i_btn[0];
    end
    else begin
        tx_data <= {4'b0000, i_sw};
        btn <= i_btn;
        if (!btn && i_btn[0])
            tx_start <= 1;
        else
            tx_start <= 0;
    end
end


BaudRateGenerator u_baud_rate(
    .clk(clk),
    .rst(rst),
    .out(baud_rate)
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
