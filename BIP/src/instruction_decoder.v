`define OPCODE_BITS 5

module InstructionDecoder(
	input clk,
	input rst,
	input [OPCODE_BITS-1:0] opcode,
	output reg [1:0] o_sel_a,
	output reg o_enable_pc,
	output reg o_sel_b,
	output reg o_write_acc,
	output reg o_operation);

always@(negedge clk)
begin
	
end

endmodule