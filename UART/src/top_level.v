
module TopLevel(
    input CLK100MHZ,
    input rst,
    input uart_txd_in,
    output uart_rxd_out,
    output [3:0] o_led
);

wire clk = CLK100MHZ;
wire tx;
wire rx = uart_txd_in;
assign uart_rxd_out = tx;


wire [7:0] A;
wire [7:0] B;
wire [5:0] opcode;
wire [7:0] alu_out;

wire baud_rate;

wire tx_start;
wire tx_done;
wire [7:0] tx_data;

wire rx_done;
wire [7:0] rx_data;

ALU u_alu(
    .A(A),
    .B(B),
    .opcode(opcode),
    .out(alu_out)
);

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

RX u_rx(
    .clk(clk),
    .rst(rst),
    .i_baud_rate(baud_rate),
    .i_rx(rx),
    .o_rx_done(rx_done),
    .o_data(rx_data)
);

Interface u_interface(
    .clk(clk),
    .rst(rst),
    .i_tx_done(tx_done),
    .i_rx_done(rx_done),
    .i_rx(rx_data),
    .i_alu_result(alu_out),
    .o_tx_start(tx_start),
    .o_tx(tx_data),
    .o_alu_a(A),
    .o_alu_b(B),
    .o_alu_opcode(opcode),
    .o_led(o_led)
);


endmodule
