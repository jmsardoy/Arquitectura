`define ADDRESS_BITS 11
`define DATA_BITS 16

module DataMemory
#(
    parameter ADDRESS_BITS = `ADDRESS_BITS,
    parameter DATA_BITS = `DATA_BITS
)
(
	input clk,
	input read,
	input write,
	input wire [ADDRESS_BITS-1:0] i_address,
	input wire [DATA_BITS-1:0] i_data,
	output reg [DATA_BITS-1:0] o_data
);
	
	localparam MEM_SIZE = 2**ADDRESS_BITS;

	reg [DATA_BITS-1:0] mem [0:MEM_SIZE-1];

	always@(posedge clk) 
	begin
		if (read)
		begin
			o_data <= mem[i_address];
		end
		else if (write)
		begin
			mem[i_address] <= i_data;
		end
	end
endmodule
