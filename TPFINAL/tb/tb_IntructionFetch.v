`timescale 1ns / 1ps


module tb_InstructionFetch();

    reg clk;
    reg rst;
    reg enable;
    reg PCSrc;
    reg [7:0] PCBranch;
    reg write_inst_mem;
    reg [7:0] inst_mem_addr;
    reg [31:0] inst_mem_data;
    wire [7:0] PCNext;
    wire [31:0] instruction;



    initial begin
        clk = 1;
        rst = 0;
        enable = 0;
        PCSrc = 0;
        PCBranch = 0;
        write_inst_mem = 0;
        inst_mem_addr = 0;
        inst_mem_data = 0;

        #20
        write_inst_mem = 1;
        inst_mem_addr = 0;
        inst_mem_data = 10;
        #20
        inst_mem_addr = 1;
        inst_mem_data = 20;
        #20
        inst_mem_addr = 2;
        inst_mem_data = 20;
    end

    always #10 clk = ~clk;


    InstructionFetch IF(
        .clk(clk),
        .rst(rst),
        .enable(enable),
        .PCSrc(PCSrc),
        .PCBranch(PCBranch),
        .write_inst_mem(write_inst_mem),
        .inst_mem_addr(inst_mem_addr),
        .inst_mem_data(inst_mem_data),
        .PCNext(PCNext),
        .instruction(instruction)
    );



endmodule
