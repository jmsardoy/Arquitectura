`timescale 1ns / 1ps

`include "constants.vh"

module HazardDetector
#(
    parameter INSTRUCTION_BITS = `INSTRUCTION_BITS,
    parameter REG_ADDRS_BITS   = `REG_ADDRS_BITS
)
(
    input wire [REG_ADDRS_BITS*2 - 1: 0] i_instruction_rs_rt,
    input wire [REG_ADDRS_BITS - 1  : 0] i_id_ex_rt,
    input wire                           i_id_ex_MemRead,
    output reg                           o_PCWrite,
    output reg                           o_if_id_write,
    output reg                           o_control_mux
);

    wire [REG_ADDRS_BITS - 1 : 0] if_id_rs = i_instruction_rs_rt[REG_ADDRS_BITS*2-1 -: REG_ADDRS_BITS];
    wire [REG_ADDRS_BITS - 1 : 0] if_id_rt = i_instruction_rs_rt[REG_ADDRS_BITS-1 : 0];

    //control_mux = 0 when we want to set all control lines to 0 and
    //control mux = 1 when we want all control lines from the control unit
    always@* begin
        if  (
                i_id_ex_MemRead &&
                (
                    (i_id_ex_rt == if_id_rs) || (i_id_ex_rt == if_id_rt)
                )
            ) 
        begin
            o_PCWrite     = 0;
            o_if_id_write = 0;
            o_control_mux = 0;
        end
        else begin
            o_PCWrite     = 1;
            o_if_id_write = 1;
            o_control_mux = 1;
        end

    
    end

endmodule
