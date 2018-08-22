`timescale 1ns / 1ps

`define ADD 8'b00100000
`define SUB 8'b00100010
`define AND 8'b00100100
`define OR  8'b00100101
`define XOR 8'b00100110
`define NOR 8'b00100111
`define SRA 8'b00000011
`define SRL 8'b00000010
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
			`SRA: out = A>>>B; 
			`SRL: out = A>>B; 
			default: out = 0;
		endcase
	end

endmodule
