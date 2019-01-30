`timescale 1ns / 1ps

`include "constants.vh"

module Control
#(
    parameter OPCODE_BITS = `OPCODE_BITS
)
(
    input wire  [OPCODE_BITS - 1 : 0] i_opcode,
    input wire                        i_control_mux,
    output reg                        o_RegDst,
    output reg  [1:0]                 o_ALUOp,
    output reg                        o_ALUSrc,
    output reg                        o_Branch,
    output reg                        o_MemRead,
    output reg                        o_MemWrite,
    output reg                        o_RegWrite,
    output reg                        o_MemtoReg
);
    localparam RFORMAT = 'b000000;
    localparam LW      = 'b100011;
    localparam SW      = 'b101011;
    localparam BEQ     = 'b000100;

    //Truth table figure 4.22 or table figure 4.49
    always@* begin
        if (i_control_mux) begin
            case (i_opcode)
                RFORMAT: begin
                    o_RegDst   <= 1;
                    o_ALUSrc   <= 0;
                    o_MemtoReg <= 0;
                    o_RegWrite <= 1;
                    o_MemRead  <= 0;
                    o_MemWrite <= 0;
                    o_Branch   <= 0;
                    o_ALUOp    <= 'b10; 
                end

                LW: begin
                    o_RegDst   <= 0;
                    o_ALUSrc   <= 1;
                    o_MemtoReg <= 1;
                    o_RegWrite <= 1;
                    o_MemRead  <= 1;
                    o_MemWrite <= 0;
                    o_Branch   <= 0;
                    o_ALUOp    <= 'b00; 
                end

                SW: begin
                    o_RegDst   <= 0; //x
                    o_ALUSrc   <= 1;
                    o_MemtoReg <= 0; //x
                    o_RegWrite <= 0; 
                    o_MemRead  <= 0;
                    o_MemWrite <= 1;
                    o_Branch   <= 0;
                    o_ALUOp    <= 'b00; 
                end

                BEQ: begin
                    o_RegDst   <= 0; //x
                    o_ALUSrc   <= 0;
                    o_MemtoReg <= 0; //x
                    o_RegWrite <= 0;
                    o_MemRead  <= 0;
                    o_MemWrite <= 0;
                    o_Branch   <= 1;
                    o_ALUOp    <= 'b01; 
                end
            endcase
        end
        else begin
            o_RegDst   <= 0;
            o_ALUSrc   <= 0;
            o_MemtoReg <= 0;
            o_RegWrite <= 0;
            o_MemRead  <= 0;
            o_MemWrite <= 0;
            o_Branch   <= 0;
            o_ALUOp    <= 'b00; 
        end
    end

endmodule
