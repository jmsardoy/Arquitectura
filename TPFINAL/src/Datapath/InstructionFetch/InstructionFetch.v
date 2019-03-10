`timescale 1ns / 1ps

`include "constants.vh"

module InstructionFetch
#(
    parameter PC_BITS          = `PC_BITS,
    parameter INSTRUCTION_BITS = `INSTRUCTION_BITS,
    parameter INST_ADDRS_BITS  = `INST_ADDRS_BITS
)
(
    input  wire clk,
    input  wire rst,
    input  wire enable,
    input  wire                             i_PCWrite,
    input  wire                             i_PCSrc,
    input  wire [PC_BITS - 1 : 0]           i_PCBranch,
    input  wire                             i_write_inst_mem,
    input  wire [PC_BITS - 1 : 0]           i_inst_mem_addr,
    input  wire [INSTRUCTION_BITS - 1 : 0]  i_inst_mem_data,
    output wire [PC_BITS - 1 : 0]           o_PCNext,
    output wire [INSTRUCTION_BITS - 1 : 0]  o_instruction
);

    localparam HLT = 0'hFFFFFFFF;

    reg [PC_BITS - 1 : 0] pc;
    reg [INSTRUCTION_BITS - 1 : 0] inst_data;
    
    wire [PC_BITS - 1 : 0] pc_plus_1;
    assign pc_plus_1 = pc + 1;
    assign o_PCNext = (o_instruction == HLT) ? pc : pc_plus_1;

    wire [PC_BITS - 1 : 0] pc_input = (i_PCSrc) ? i_PCBranch : o_PCNext;
    wire [PC_BITS - 1 : 0] mem_addr = (i_write_inst_mem) ? i_inst_mem_addr : pc;

    always@(posedge clk) begin
        if (~rst) begin
            pc <= 0;
        end
        else begin
            //enable and write_inst_mem come from Debug
            if (enable & ~i_write_inst_mem) begin
                //PCWrite is the signal comming from Hazard Detector Unit
                if (i_PCWrite) pc <= pc_input;
            end
        end
    end

    BRAM  #(
        .ADDRESS_BITS(INST_ADDRS_BITS),
        .DATA_BITS(INSTRUCTION_BITS)
    ) instruction_memory (
        .clk(clk),
        .write_enable(i_write_inst_mem),
        .i_address(mem_addr[INST_ADDRS_BITS - 1 : 0]),
        .i_data(i_inst_mem_data),
        .o_data(o_instruction)
    );

endmodule
