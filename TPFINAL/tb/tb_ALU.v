`timescale 1ns/1ps

`include "constants.vh"

module tb_ALU();
    localparam PROC_BITS = `PROC_BITS;

    reg [PROC_BITS - 1 : 0] dataA;
    reg [PROC_BITS - 1 : 0] dataB;
    reg [3 : 0]             operation;

    wire [PROC_BITS - 1 : 0] result;


    localparam ADD  = 'b0000;
    localparam SUB  = 'b0001;
    localparam AND  = 'b0010;
    localparam OR   = 'b0011;
    localparam XOR  = 'b0100;
    localparam NOR  = 'b0101;
    localparam SLT  = 'b0110;
    localparam SLL  = 'b0111;
    localparam SRL  = 'b1000;
    localparam SRA  = 'b1001;
    localparam LUI =  'b1010;

    initial begin
        operation = ADD;
        dataA = -55;
        dataB = 8;
        #20;

        operation = SUB;
        dataA = 40;
        dataB = 50;
        #20;

        operation = AND;
        dataA = 40;
        dataB = 50;
        #20;

        operation = OR;
        dataA = 40;
        dataB = 50;
        #20;

        operation = XOR;
        dataA = 40;
        dataB = 50;
        #20;

        operation = NOR;
        dataA = 40;
        dataB = 50;
        #20;

        //positive case
        operation = SLT;
        dataA = 40;
        dataB = 50;
        #20;

        //negative case
        operation = SLT;
        dataA = 60;
        dataB = 50;
        #20;

        //recall that dataB<<dataA (dataA is Shamt)
        operation = SLL;
        dataA = 5;
        dataB = 40;
        #20;

        //recall that dataB>>dataA (dataA is Shamt)
        operation = SRL;
        dataA = 5;
        dataB = 40;
        #20;

        //negative signe
        //recall that dataB>>>dataA (dataA is Shamt)
        operation = SRA;
        dataA = 5;
        dataB = 85;
        #20;

        //positive signe
        //recall that dataB>>>dataA (dataA is Shamt)
        operation = SRA;
        dataA = 5;
        dataB = -85;
        #20;

        operation = LUI;
        dataB = 61;

        #20;

        //end
        operation = 0;
        dataA = 0;
        dataB = 0;
        
    end



    ALU alu_u(
        .i_dataA(dataA),
        .i_dataB(dataB),
        .i_operation(operation),
        .o_result(result)
    );
 

endmodule
 
