`timescale 1ns / 1ps

`include "constants.vh"

module SevenSegmentDecoder(
    input [2:0] i_debug_state,
    output reg [6:0] o_seg
);

    localparam IDLE       = 0;
    localparam START_LOAD = 1;
    localparam WAIT_LOAD  = 2;
    localparam START_RUN  = 3;
    localparam WAIT_RUN   = 4;
    localparam START_STEP = 5;
    localparam WAIT_STEP  = 6;


    always@* begin
        case(i_debug_state) 
            WAIT_LOAD: begin
                o_seg[0] = 1;
                o_seg[1] = 1;
                o_seg[2] = 1;
                o_seg[3] = 0;
                o_seg[4] = 0;
                o_seg[5] = 0;
                o_seg[6] = 1;
            end
            WAIT_RUN: begin
                o_seg[0] = 0;
                o_seg[1] = 1;
                o_seg[2] = 1;
                o_seg[3] = 1;
                o_seg[4] = 0;
                o_seg[5] = 0;
                o_seg[6] = 1;
            end
            WAIT_STEP: begin
                o_seg[0] = 0;
                o_seg[1] = 1;
                o_seg[2] = 0;
                o_seg[3] = 0;
                o_seg[4] = 1;
                o_seg[5] = 0;
                o_seg[6] = 0;
            end
            default: begin
                o_seg[0] = 1;
                o_seg[1] = 1;
                o_seg[2] = 1;
                o_seg[3] = 1;
                o_seg[4] = 1;
                o_seg[5] = 1;
                o_seg[6] = 0;
            end


        endcase
    end
    

endmodule

