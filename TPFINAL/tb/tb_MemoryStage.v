`timescale 1ns / 1ps

`include "constants.vh"

module tb_MemoryStage();

    localparam PC_BITS         = `PC_BITS;
    localparam PROC_BITS       = `PROC_BITS;
    localparam REG_ADDRS_BITS  = `REG_ADDRS_BITS;
    localparam DATA_ADDRS_BITS = `DATA_ADDRS_BITS;

    reg clk;
    reg [PROC_BITS - 1 : 0] i_alu_data;
    reg [PROC_BITS - 1 : 0] store_data;
    reg [REG_ADDRS_BITS - 1 : 0] i_rd;
    reg i_pc_to_reg;
    reg [PC_BITS - 1 : 0] i_pc_return;
    reg i_RegWrite;
    reg MemRead;
    reg MemWrite;
    reg i_MemtoReg;
    reg [2:0] ls_filter_op;
    
    wire [PROC_BITS - 1 : 0] o_alu_data;
    wire [REG_ADDRS_BITS - 1 : 0] o_rd;
    wire [PROC_BITS - 1 : 0] mem_data;
    wire o_pc_to_reg;
    wire [PC_BITS - 1 : 0] o_pc_return;
    wire o_RegWrite;
    wire o_MemtoReg;


    integer i;

    initial begin
        clk = 0;

        //this test doesn't check for load filter and store filters
        //cause reasons.

        //test writes
        MemRead = 0;
        MemWrite = 1;
        for (i=0; i<10; i=i+1) begin
            i_alu_data = i;
            store_data = i*100;
            #20;
        end


        //test reads
        MemRead = 1;
        MemWrite = 0;
        for (i=0; i<10; i=i+1) begin
            i_alu_data = i;
            #20;
            if (mem_data != i*100) $finish();
        end
        
    end

    always #10 clk = ~clk;

    MemoryStage mem_stage_u(
        .clk(clk),
        .i_alu_data(i_alu_data),
        .i_store_data(store_data),
        .i_rd(i_rd),
        .i_pc_to_reg(i_pc_to_reg),
        .i_pc_return(i_pc_return),
        .i_RegWrite(i_RegWrite),
        .i_MemRead(MemRead),
        .i_MemWrite(MemWrite),
        .i_MemtoReg(i_MemtoReg),
        .i_ls_filter_op(ls_filter_op),
        .o_alu_data(o_alu_data),
        .o_mem_data(mem_data),
        .o_rd(o_rd),
        .o_pc_to_reg(o_pc_to_reg),
        .o_pc_return(o_pc_return),
        .o_RegWrite(o_RegWrite),
        .o_MemtoReg(o_MemtoReg)
    );


endmodule

