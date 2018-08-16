`timescale 1ns / 1ps

module ALU 
	#(parameter bus=8)
	(input signed [bus-1:0]A, input signed [bus-1:0]B,input [7:0]Opcode,
	output reg[bus-1:0]Out);
	always@(*)
	begin
		case (Opcode)
			8'b00100000: Out=A+B; //ADD
			8'b00100010: Out=A-B; //SUB
			8'b00100100: Out=A&B; //AND
			8'b00100101: Out=A|B; //OR
			8'b00100110: Out=A^B; //XOR
			8'b00100111: Out=~(A|B); //NOR
			8'b00000011: Out=A>>>B; //SRA
			8'b00000010: Out=A>>B; //SRL
			default: Out= 0;
		endcase
	end

endmodule
