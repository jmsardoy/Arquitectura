`timescale 1ns/1ps

`define ADDRESS_BITS 8
`define DATA_BITS 32

module BRAM
#(
    parameter ADDRESS_BITS = `ADDRESS_BITS,
    parameter DATA_BITS = `DATA_BITS
)
(
	input clk,
    input write_enable,
	input wire [ADDRESS_BITS-1:0] i_address,
	input wire [DATA_BITS-1:0] i_data,
	output reg [DATA_BITS-1:0] o_data
);

	localparam MEM_SIZE = 2**ADDRESS_BITS;

	reg [DATA_BITS-1:0] mem [0:MEM_SIZE-1];

    /*
    initial begin
        $readmemb("testasm.mem", mem);
    end
    */

	always@(posedge clk)
	begin
		if (write_enable) mem[i_address] <= i_data;
	end

    always@(negedge clk) begin
	    o_data <= mem[i_address];
    end

endmodule
