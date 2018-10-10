`define ADDRESS_BITS 11
`define DATA_BITS 16

module ProgramMemory(
	input clk,
	input rst,
	input reg[ADDRESS_BITS-1:0] i_address,
	output reg[DATA_BITS-1:0] o_data
);
	
	`localparam MEM_SIZE = 2**`ADDRESS_BITS;

	reg[DATA_BITS-1:0] mem [0:MEM_SIZE-1];

	@always(posedge clk)
		begin
		if(rst==0)
			begin
			`define DATA_MEMORY(address, data) memory[adress] = data;
			`include "program.vh"
			end
		else
			begin
				o_data = mem[i_address];
			end
		end
endmodule