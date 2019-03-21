`timescale 1ns/1ps

`include "constants.vh"

module tb_StoreFilter();

    localparam PROC_BITS = `PROC_BITS;

    reg [PROC_BITS - 1 : 0]  data_in;
    reg [2 : 0]              ls_filter_op;
    wire [PROC_BITS - 1 : 0] data_out;

    localparam STORE_BYTE          = 3'b000;
    localparam STORE_HEX           = 3'b001;
    localparam STORE_WORD          = 3'b011;

    initial begin
        //testing SB (positive)
        ls_filter_op = STORE_BYTE;
        data_in =     32'b01010111100001110000111001001001;
        #20
        if (data_out != 'b00000000000000000000000001001001) $finish;
        #20

        //testing SB (negative)
        ls_filter_op = STORE_BYTE;
        data_in =     32'b01010111100001110000111011001001;
        #20
        if (data_out != 'b00000000000000000000000011001001) $finish;
        #20

        //testing SH (positive)
        ls_filter_op = STORE_HEX;
        data_in =     32'b01010111100001110000111011001001;
        #20
        if (data_out != 'b00000000000000000000111011001001) $finish;
        #20

        //testing SH (negative)
        ls_filter_op = STORE_HEX;
        data_in =     32'b01010111100001111000111011001001;
        #20
        if (data_out != 'b00000000000000001000111011001001) $finish;
        #20

        //testing SW 
        ls_filter_op = STORE_WORD;
        data_in =     32'b01010111100001111000111011001001;
        #20
        if (data_out != 'b01010111100001111000111011001001) $finish;
        #20
    ;
    end
    
    StoreFilter store_filter_u(
        .i_data_in(data_in),
        .i_ls_filter_op(ls_filter_op),
        .o_data_out(data_out)
    );

endmodule

