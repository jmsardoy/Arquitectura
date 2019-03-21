`timescale 1ns/1ps

module test_clk_50mhz();

    reg clk;
    reg rst;
    wire clk_50;


    initial begin
        clk = 1;
        rst = 0;

        #100;
        rst = 1;
    end
    

    always #10 clk = ~clk;

    clk_50Mhz clk_u(
        .reset_0(rst),
        .sys_clock(clk),
        .clk_out(clk_50)
    );


endmodule

