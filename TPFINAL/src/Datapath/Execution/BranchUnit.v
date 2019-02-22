`timescale 1ns/1ps

`include "constants.vh"

module BranchUnit
#(
    parameter OPCODE_BITS = `OPCODE_BITS,
    parameter PROC_BITS   = `PROC_BITS,
    parameter PC_BITS     = `PC_BITS,
    parameter FUNCT_BITS  = `FUNCT_BITS
)
(
    input wire                       i_branch_enable,
    input wire [OPCODE_BITS - 1 : 0] i_opcode,
    input wire [FUNCT_BITS - 1 : 0]  i_funct,
    input wire [PC_BITS - 1 : 0]     i_pc_next,
    input wire [PROC_BITS - 1 : 0]   i_immediate,
    input wire [PROC_BITS - 1 : 0]   i_jump_address,
    input wire [PROC_BITS - 1 : 0]   i_data_rs,
    input wire [PROC_BITS - 1 : 0]   i_data_rt,

    output reg o_taken,
    output reg o_pc_to_reg,
    output reg [PC_BITS - 1 : 0] o_jump_address,
    output reg [PC_BITS - 1 : 0] o_pc_return,
    output reg o_pc_reg_sel

);

    localparam BEQ     = 'b000100;
    localparam BNE     = 'b000101;
    localparam J       = 'b000010;
    localparam JAL     = 'b000011;
    localparam JR_JALR = 'b000000;

    always@* begin
        o_pc_return = i_pc_next;
        if (i_branch_enable) begin
            case (i_opcode)
                BEQ: begin
                    o_taken = i_data_rs == i_data_rt;
                    o_pc_to_reg = 0;
                    o_jump_address = (i_pc_next + i_immediate);
                    o_pc_reg_sel = 0;
                end
                BNE: begin
                    o_taken = i_data_rs != i_data_rt;
                    o_pc_to_reg = 0;
                    o_jump_address = (i_pc_next + i_immediate);
                    o_pc_reg_sel = 0;
                end
                J: begin
                    o_taken = 1;
                    o_pc_to_reg = 0;
                    o_jump_address = i_jump_address;
                    o_pc_reg_sel = 0;
                end
                JAL: begin
                    o_taken = 1;
                    o_pc_to_reg = 1;
                    o_jump_address = i_jump_address;
                    o_pc_reg_sel = 1;
                end
                JR_JALR: begin
                    //JR
                    if (i_funct == 'b001000) begin
                        o_taken = 1;
                        o_pc_to_reg = 0;
                        o_jump_address = i_data_rs;
                        o_pc_reg_sel = 0;
                    end
                    //JALR
                    else if (i_funct == 'b001001) begin
                        o_taken = 1;
                        o_pc_to_reg = 1;
                        o_jump_address = i_data_rs;
                        o_pc_reg_sel = 0;
                    end
                    //NO JUMP
                    else begin
                        o_taken = 0;
                        o_pc_to_reg = 0;
                        o_jump_address = 0;
                        o_pc_reg_sel = 0;
                    end
                end
                //NO JUMP
                default: begin
                    o_taken = 0;
                    o_pc_to_reg = 0;
                    o_jump_address = 0;
                    o_pc_reg_sel = 0;
                
                end
            endcase
        end
        else begin
            o_taken = 0;
            o_pc_to_reg = 0;
            o_jump_address = 0;
            o_pc_reg_sel = 0;
        end
    end
endmodule
