

module TBInterface();
    

    reg clk;
    reg rst;
    wire [15:0] accumulator;
    wire [7 :0] inst_count;
    wire bip_done;
    wire tx;



    initial begin
        clk = 0;
        rst = 0;
        #2 rst = 1;
    end
    
    always #1 clk = ~clk;

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
        .o_tx(tx)
    );

endmodule
