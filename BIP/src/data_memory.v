`define ADDRESS_BITS 11
`define DATA_BITS 16

module DataMemory(
	input clk,
	input read,
	input write,
	input reg[ADDRESS_BITS-1:0] i_address,
	input reg [DATA_BITS-1:0] i_data,
	output reg[DATA_BITS-1:0] o_data
);
	
	`localparam MEM_SIZE = 2**`ADDRESS_BITS;

	reg[DATA_BITS-1:0] mem [0:MEM_SIZE-1];

	@always(posedge clk) 
	begin
		if (read)
		begin
			o_data = mem[i_address];
		end
		else if (write)
		begin
			mem[i_address] = i_data;
		end
	end
endmodule