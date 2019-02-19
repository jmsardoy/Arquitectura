`timescale 1ns/1ps

`include "constants.vh"

module LoadFilter
#(
    parameter PROC_BITS = `PROC_BITS
)
(
    input wire [PROC_BITS - 1 : 0] i_data_in,
    input wire [2:0]               i_ls_filter_op,
    output reg [PROC_BITS - 1 : 0] o_data_out
);

    localparam LOAD_BYTE          = 3'b000;
    localparam LOAD_HEX           = 3'b001;
    localparam LOAD_WORD          = 3'b011;
    localparam LOAD_BYTE_UNSIGNED = 3'b100;
    localparam LOAD_HEX_UNSIGNED  = 3'b101;

    always@* begin
        case (i_ls_filter_op)
            LOAD_BYTE:          o_data_out = {{24{i_data_in[7]}}, i_data_in[7:0]};
            LOAD_HEX:           o_data_out = {{16{i_data_in[15]}}, i_data_in[15:0]};
            LOAD_WORD:          o_data_out = i_data_in;
            LOAD_BYTE_UNSIGNED: o_data_out = {{24{1'b0}}, i_data_in[7:0]};
            LOAD_HEX_UNSIGNED:  o_data_out = {{16{1'b0}}, i_data_in[15:0]};
            default:            o_data_out = i_data_in;
        endcase
    end

endmodule
