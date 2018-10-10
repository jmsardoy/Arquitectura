
module tb_interface();
    reg clk, rst;

    wire [7 : 0] A;
    wire [7 : 0] B;
    wire [5 : 0] opcode;
    wire [7 : 0] alu_out;
    

    reg tx_done;
    reg rx_done;
    reg [7:0] rx_data;
    wire [7:0] tx_data;
    wire tx_start;

    ALU alu(
        .A(A),
        .B(B),
        .opcode(opcode),
        .out(alu_out)
    );
    Interface uut(
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
        .o_alu_opcode(opcode)
    );
    initial begin
        clk = 0;
        rst = 0;
        tx_done = 1;
        rx_done = 0;
        rx_data = 0;

        #2 rst = 1;
        #10 rx_data = 10;
        #2 rx_done = 1;
        #2 rx_done = 0;
        #10 rx_data = 20;
        #2 rx_done = 1;
        #2 rx_done = 0;
        #10 rx_data = 32;
        #2 rx_done = 1;
        #2 rx_done = 0;

    end

    always #1 clk = ~clk;
endmodule
