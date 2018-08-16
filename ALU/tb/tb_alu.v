`timescale 1ns / 1ps

`define ADD 6'b100000
`define SUB 6'b100010
`define AND 6'b100100
`define OR  6'b100101
`define XOR 6'b100110
`define NOR 6'b100111
`define SRA 6'b000011
`define SRL 6'b000010

module tb_alu();


    reg signed [7:0] A;
    reg signed [7:0] B;
    reg [5:0] opcode;
    wire [7:0] out;
        
    ALU
        #(
        .bus (8)
        )
    u_ALU(
        .A (A),
        .B (B),
        .opcode (opcode),
        .out (out)
        );

    initial begin
        opcode = 0;
        A = 0;
        B = 0;
        
        #10
        A = 5;
        B = 3;
        opcode = `ADD;
        #10
        opcode = `SUB;
        #10
        opcode = `AND;
        #10
        opcode = `OR;
        #10
        opcode = `XOR;
        #10
        opcode = `NOR;
        #10
        opcode = `SRA;
        #10
        opcode = `SRL;
    end


endmodule
