`timescale 1ns / 1ps


module InstructionFetch(
    input wire clk,
    input wire rst,
    input wire enable,
    input wire PCSrc,
    input wire [7:0] PCBranch,
    output wire [7:0] PCNext,
    output wire [31:0] instruction
);

    reg write_enable;
    reg [7:0] pc;
    reg [31 : 0] inst_data;
    
    PCNext = pc + 1;
    wire pc_input = (PCSrc) ? PCBranch : PCNext;

    always@(posedge clk) begin
        if (~rst) begin
            pc <= 0;
            write_enable <= 0;
            inst_data <= 0;
        end
        else begin
            if (enable) begin
                pc <= pc_input;
            end
        end
    end

    BRAM  #(
        .ADDRESS_BITS(8),
        .DATA_BITS(32)
    ) instruction_memory (
        clk(clk),
        write_enable(write_enable),
        i_address(pc),
        i_data(inst_data),
        output_data(instruction)
    );

endmodule
