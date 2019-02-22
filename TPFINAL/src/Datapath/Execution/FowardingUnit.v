`timescale 1ns / 1ps

`include "constants.vh"

module FowardingUnit
#(
    parameter REG_ADDRS_BITS = `REG_ADDRS_BITS
)
(
    input wire i_ex_mem_RegWrite,
    input wire i_mem_wb_RegWrite,
    input wire [REG_ADDRS_BITS - 1 : 0] i_id_ex_rs,
    input wire [REG_ADDRS_BITS - 1 : 0] i_id_ex_rt,
    input wire [REG_ADDRS_BITS - 1 : 0] i_ex_mem_rd,
    input wire [REG_ADDRS_BITS - 1 : 0] i_mem_wb_rd,

    output reg [1:0] o_foward_A,
    output reg [1:0] o_foward_B
);

    reg mem_foward_a;
    reg mem_foward_b;
    reg wb_foward_a;
    reg wb_foward_b;

    always@* begin
        
        mem_foward_a = i_ex_mem_RegWrite && (i_ex_mem_rd != 0) &&
                       (i_ex_mem_rd == i_id_ex_rs);
        mem_foward_b = i_ex_mem_RegWrite && (i_ex_mem_rd != 0) &&
                       (i_ex_mem_rd == i_id_ex_rt);
        wb_foward_a  = i_mem_wb_RegWrite && (i_mem_wb_rd != 0) &&
                       (i_mem_wb_rd == i_id_ex_rs);
        wb_foward_b  = i_mem_wb_RegWrite && (i_mem_wb_rd != 0) &&
                       (i_mem_wb_rd == i_id_ex_rt);

        if (mem_foward_a)     o_foward_A = 'b10;
        else if (wb_foward_a) o_foward_A = 'b01;
        else                  o_foward_A = 'b00;

        if (mem_foward_b)     o_foward_B = 'b10;
        else if (wb_foward_b) o_foward_B = 'b01;
        else                  o_foward_B = 'b00;

    end

endmodule
