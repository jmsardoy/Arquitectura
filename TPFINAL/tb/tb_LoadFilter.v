`timescale 1ns/1ps

`include "constants.vh"

module tb_LoadFilter();

    localparam PROC_BITS = `PROC_BITS;

    reg [PROC_BITS - 1 : 0]  data_in;
    reg [2 : 0]              ls_filter_op;
    wire [PROC_BITS - 1 : 0] data_out;

    localparam LOAD_BYTE          = 3'b000;
    localparam LOAD_HEX           = 3'b001;
    localparam LOAD_WORD          = 3'b011;
    localparam LOAD_BYTE_UNSIGNED = 3'b100;
    localparam LOAD_HEX_UNSIGNED  = 3'b101;


    initial begin
        //testing LB (positive)
        ls_filter_op = LOAD_BYTE;
        data_in =     32'b01010111100001110000111001001001;
        #20
        if (data_out != 'b00000000000000000000000001001001) $finish;
        #20

        //testing LB (negative)
        ls_filter_op = LOAD_BYTE;
        data_in =     32'b01010111100001110000111011001001;
        #20
        if (data_out != 'b11111111111111111111111111001001) $finish;
        #20

        //testing LH (positive)
        ls_filter_op = LOAD_HEX;
        data_in =     32'b01010111100001110000111011001001;
        #20
        if (data_out != 'b00000000000000000000111011001001) $finish;
        #20

        //testing LH (negative)
        ls_filter_op = LOAD_HEX;
        data_in =     32'b01010111100001111000111011001001;
        #20
        if (data_out != 'b11111111111111111000111011001001) $finish;
        #20

        //testing LW 
        ls_filter_op = LOAD_WORD;
        data_in =     32'b01010111100001111000111011001001;
        #20
        if (data_out != 'b01010111100001111000111011001001) $finish;
        #20

        //testing LBU (positive)
        ls_filter_op = LOAD_BYTE_UNSIGNED;
        data_in =     32'b01010111100001110000111001001001;
        #20
        if (data_out != 'b00000000000000000000000001001001) $finish;
        #20

        //testing LBU (negative)
        ls_filter_op = LOAD_BYTE_UNSIGNED;
        data_in =     32'b01010111100001110000111011001001;
        #20
        if (data_out != 'b00000000000000000000000011001001) $finish;
        #20

        //testing LHU (positive)
        ls_filter_op = LOAD_HEX_UNSIGNED;
        data_in =     32'b01010111100001110000111011001001;
        #20
        if (data_out != 'b00000000000000000000111011001001) $finish;
        #20

        //testing LHU (negative)
        ls_filter_op = LOAD_HEX_UNSIGNED;
        data_in =     32'b01010111100001111000111011001001;
        #20
        if (data_out != 'b00000000000000001000111011001001) $finish;
        #20
    ;
    end
    
    LoadFilter load_filter_u(
        .i_data_in(data_in),
        .i_ls_filter_op(ls_filter_op),
        .o_data_out(data_out)
    );

endmodule

