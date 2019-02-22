`timescale 1ns/1ps

`include "constants.vh"

module StoreFilter
#(
    parameter PROC_BITS = `PROC_BITS
)
(
    input wire [PROC_BITS - 1 : 0] i_data_in,
    input wire [2:0]               i_ls_filter_op,
    output reg [PROC_BITS - 1 : 0] o_data_out
);

    localparam STORE_BYTE          = 3'b000;
    localparam STORE_HEX           = 3'b001;
    localparam STORE_WORD          = 3'b011;

    always@* begin
        case (i_ls_filter_op)
            STORE_BYTE: o_data_out = {{24{1'b0}}, i_data_in[7:0]};
            STORE_HEX:  o_data_out = {{16{1'b0}}, i_data_in[15:0]};
            STORE_WORD: o_data_out = i_data_in;
            default:    o_data_out = i_data_in;
        endcase
    end

endmodule
