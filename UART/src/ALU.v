`timescale 1ns / 1ps

`define ADD 6'b100000
`define SUB 6'b100010
`define AND 6'b100100
`define OR  6'b100101
`define XOR 6'b100110
`define NOR 6'b100111
`define SRA 6'b000011
`define SRL 6'b000010
`define BUS_LEN 8

module ALU 
	#(parameter BUS_LEN = `BUS_LEN)
	(
        input signed [BUS_LEN-1:0] A, 
        input signed [BUS_LEN-1:0] B,
        input [5:0] opcode,
	    output reg signed [BUS_LEN-1:0] out
    );

    always@(*)
	begin
		case (opcode)
			`ADD: out = A+B; 
			`SUB: out = A-B; 
			`AND: out = A&B; 
			`OR : out = A|B; 
			`XOR: out = A^B; 
			`NOR: out = ~(A|B); 
			`SRA: out = A >>> (B % BUS_LEN);
            `SRL: out = A >> B;
			default: out = 0;
		endcase
	end

endmodule
