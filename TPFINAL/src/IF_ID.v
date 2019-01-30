`timescale 1ns / 1ps

`include "constants.vh"

module IF_ID
#(
    parameter PC_BITS          = `PC_BITS,
    parameter INSTRUCTION_BITS = INSTRUCTION_BITS
)
(
    input clk,
    input                                  i_if_id_write,
    input wire [PC_BITS - 1 : 0]           i_PCNext,
    input wire [INSTRUCTION_BITS - 1 : 0]  i_instruction,
    output reg [PC_BITS - 1 : 0]           o_PCNext,
    output reg [INSTRUCTION_BITS - 1 : 0]  o_instruction,
);

    always@(posedge clk) begin
        if(i_if_id_write) begin
            o_PCNext <= i_PCNext;
            o_instruction <= i_instruction;
        end
    end

endmodule
