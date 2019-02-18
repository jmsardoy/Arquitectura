`timescale 1ns/1ps

`include "constants.vh"

module ALU
#(
    parameter PROC_BITS = `PROC_BITS
)
(
    input wire [PROC_BITS - 1 : 0] i_dataA,
    input wire [PROC_BITS - 1 : 0] i_dataB,
    input wire [3 : 0 ]            i_operation,

    output reg [PROC_BITS - 1 : 0] o_result

);

    localparam ADD  = 'b0000;
    localparam SUB  = 'b0001;
    localparam AND  = 'b0010;
    localparam OR   = 'b0011;
    localparam XOR  = 'b0100;
    localparam NOR  = 'b0101;
    localparam SLT  = 'b0110;
    localparam SLL  = 'b0111;
    localparam SRL  = 'b1000;
    localparam SRA  = 'b1001;
    localparam LUI  = 'b1010;



    always@* begin
        case (i_operation)
            ADD: o_result = i_dataA + i_dataB;
            SUB: o_result = i_dataA - i_dataB;
            AND: o_result = i_dataA & i_dataB;
            OR:  o_result = i_dataA | i_dataB;
            XOR: o_result = i_dataA ^ i_dataB;
            NOR: o_result = ~(i_dataA | i_dataB);
            SLT: o_result = $signed(i_dataA) < $signed(i_dataB);
            SLL: o_result = i_dataB << i_dataA;
            SRL: o_result = i_dataB >> i_dataA;
            SRA: o_result = $signed(i_dataB) >>> i_dataA;
            LUI: o_result = i_dataB << 16;
            default: o_result = 0;
        endcase
    
    
    end

endmodule
