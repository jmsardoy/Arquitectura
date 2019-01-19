`timescale 1ns / 1ps

`include "constants.vh"

module RegisterFile
#(
	// -1 to have MSB index ready
    parameter REG_ADDRS_BITS_I 	= `REG_ADDRS_BITS - 1,
    parameter PROC_BITS_I	 	= `PROC_BITS - 1
)
(
	input wire clk,
	input wire 							i_reg_write,
	input wire 	[REG_ADDRS_BITS_I:0] 	i_read_register_1,
	input wire 	[REG_ADDRS_BITS_I:0] 	i_read_register_2,
	input wire 	[REG_ADDRS_BITS_I:0] 	i_write_register,
	input wire 	[PROC_BITS_I	 :0] 	i_write_data,
	output reg  [PROC_BITS_I	 :0] 	o_read_data_1,
	output reg  [PROC_BITS_I	 :0] 	o_read_data_2,
	output wire [(32*32)-1:0] 			o_debug_regs
); 

	localparam REG_COUNT = 2**(REG_ADDRS_BITS_I + 1);

	reg [PROC_BITS_I:0] registers [0:REG_COUNT];

	integer i;
	for (i=0; i<32; i=i+1) begin
		assign o_debug_regs[(i+1)*32-1:i*32] = registers[i]; 
	end 

	always@(negedge clk) begin
		o_read_data_1 <= registers[i_read_register_1];
		o_read_data_2 <= registers[i_read_register_2];
		if (i_reg_write) begin
			registers[i_write_register] <= i_write_data;
		end
	end

	always