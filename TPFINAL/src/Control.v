`timescale 1ns / 1ps

`include "constants.vh"

module Control
#(
    parameter OPCODE_BITS = `OPCODE_BITS
)
(
    input wire [OPCODE_BITS - 1 : 0] i_opcode,
    input wire [5: 0]                i_funct,
    input wire                       i_control_mux,
    output reg                       o_RegDst,
    output reg                       o_RegWrite,
    output reg                       o_MemRead,
    output reg                       o_MemWrite,
    output reg                       o_MemtoReg,
    output reg [3:0]                 o_ALUOp,
    output reg                       o_ALUSrc,
    output reg                       o_Shamt,
    output reg [2:0]                 o_ls_filter_op
);

    localparam LW      = 'b100;
    localparam SW      = 'b101;
    localparam INMED   = 'b001;
    localparam OTHER   = 'b000;



    //Truth table figure 4.22 or table figure 4.49
    always@* begin
        o_ls_filter_op  = i_opcode[2:0];

        if (i_control_mux) begin
            case (i_opcode[5:3])
                LW: begin
                    o_RegDst   = 0;
                    o_RegWrite = 1;
                    o_MemRead  = 1;
                    o_MemWrite = 0;
                    o_MemtoReg = 1;
                    o_ALUOp    = 'b0001;
                    o_ALUSrc   = 1;
                    o_Shamt    = 0;
                end
 
                SW: begin
                    o_RegDst   = 0; //x
                    o_RegWrite = 0;
                    o_MemRead  = 0;
                    o_MemWrite = 1;
                    o_MemtoReg = 0; //x
                    o_ALUOp    = 'b0001;
                    o_ALUSrc   = 1;
                    o_Shamt    = 0;
                end

                INMED: begin
                    o_RegDst   = 0; 
                    o_RegWrite = 1;
                    o_MemRead  = 0;
                    o_MemWrite = 0;
                    o_MemtoReg = 0; 
                    o_ALUOp    = {1'b1, i_opcode[2:0]};
                    o_ALUSrc   = 1;
                    o_Shamt    = 0;
                end
                    
                OTHER: begin
                    //BRANCH
                    if (i_opcode[2]) begin
                        o_RegDst   = 0; 
                        o_RegWrite = 0;
                        o_MemRead  = 0;
                        o_MemWrite = 0;
                        o_MemtoReg = 0; 
                        o_ALUOp    = 'b0000;
                        o_ALUSrc   = 0;
                        o_Shamt    = 0;
                    end

                    //J-JAL
                    else if (i_opcode[1]) begin
                        o_RegDst   = 0; 
                        o_RegWrite = i_opcode[0];
                        o_MemRead  = 0;
                        o_MemWrite = 0;
                        o_MemtoReg = 0; 
                        o_ALUOp    = 'b0000;
                        o_ALUSrc   = 0;
                        o_Shamt    = 0;
                    end

                    //RTYPE or JR-JRAL
                    else if (i_opcode == 0) begin

                        //JR-JRAL
                        if (i_funct[5:1] == 'b00100) begin
                            o_RegDst   = i_funct[0]; 
                            o_RegWrite = i_funct[0];
                            o_MemRead  = 0;
                            o_MemWrite = 0;
                            o_MemtoReg = 0; 
                            o_ALUOp    = 'b0000;
                            o_ALUSrc   = 0;
                            o_Shamt    = 0;
                        end

                        //RTYPE
                        else begin
                            o_RegDst   = 1; 
                            o_RegWrite = 1;
                            o_MemRead  = 0;
                            o_MemWrite = 0;
                            o_MemtoReg = 0; 
                            o_ALUOp    = 'b0000;
                            o_ALUSrc   = 0;
                            o_Shamt    = (i_funct[5:2] == 0);
                        end
                    end

                    //default
                    else begin
                        o_RegDst   = 0; 
                        o_RegWrite = 0;
                        o_MemRead  = 0;
                        o_MemWrite = 0;
                        o_MemtoReg = 0; 
                        o_ALUOp    = 'b0000;
                        o_ALUSrc   = 0;
                        o_Shamt    = 0;
                    end

                end

                default: begin
                    o_RegDst   = 0; 
                    o_RegWrite = 0;
                    o_MemRead  = 0;
                    o_MemWrite = 0;
                    o_MemtoReg = 0; 
                    o_ALUOp    = 'b0000;
                    o_ALUSrc   = 0;
                    o_Shamt    = 0;
                end
            endcase
        end

        else begin
            o_RegDst   = 0; 
            o_RegWrite = 0;
            o_MemRead  = 0;
            o_MemWrite = 0;
            o_MemtoReg = 0; 
            o_ALUOp    = 'b0000;
            o_ALUSrc   = 0;
            o_Shamt    = 0;
        end
    
    end

endmodule
