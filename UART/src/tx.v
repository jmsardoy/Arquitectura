
`define NBITS 8

module Tx 
    #(parameter NBITS = `NBITS)
    (input clk,
     input rst,
     input i_baud_rate,
     input i_d_in,
     input i_tx_start,
     output o_tx_done,
     output [NBITS-1: 0] o_tx_out);


    reg [5:0] count;
    reg baud_rate;
    reg tick_enable;

     always@(posedge clk or negedge rst) begin
        if(!rst) count = 0;
        else begin
            baud_rate <= i_baud_rate;
            //detector de flanco
            if (!baud_rate && i_baud_rate) begin
                if (tick_enable) count <= count+1;
            end
        end
     end


endmodule
