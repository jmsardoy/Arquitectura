`timescale 1ns / 1ps


module InstructionFetch(
    input wire clk,
    input wire rst,
    input wire enable,
    input wire PCSrc,
    input wire [7:0] PCBranch,
    input wire write_inst_mem,
    input wire [7:0] inst_mem_addr,
    input wire [31:0] inst_mem_data,
    output wire [7:0] PCNext,
    output wire [31:0] instruction
);

    reg [7 : 0] pc;
    reg [31 : 0] inst_data;
    
    assign PCNext = pc + 1;
    wire pc_input = (PCSrc) ? PCBranch : PCNext;
    wire mem_addr = (write_inst_mem) ? inst_mem_addr : pc;

    always@(posedge clk) begin
        if (~rst) begin
            pc <= 0;
        end
        else begin
            if (enable & ~write_inst_mem) begin
                pc <= pc_input;
            end
        end
    end

    BRAM  #(
        .ADDRESS_BITS(8),
        .DATA_BITS(32)
    ) instruction_memory (
        .clk(clk),
        .write_enable(write_inst_mem),
        .i_address(mem_addr),
        .i_data(inst_mem_data),
        .o_data(instruction)
    );

endmodule
