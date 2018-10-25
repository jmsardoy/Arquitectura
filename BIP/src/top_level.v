

module TopLevel
(
    input clk,
    input rst,
    //input inv_rst,
    output tx_out
);
    
    //wire rst = ~inv_rst;
    wire [15:0] accumulator;
    wire [ 7:0] inst_count;
    wire bip_done;

    BIP bip_u 
    (
        .clk(clk),
        .rst(rst),
        .accumulator(accumulator),
        .inst_count(inst_count),
        .done(bip_done)
    );

    Interface interface_u
    (
        .clk(clk),
        .rst(rst),
        .accumulator(accumulator),
        .inst_count(inst_count),
        .bip_done(bip_done),
        .o_tx(tx_out)
    );
endmodule
