`timescale 1ns / 1ps

`include "constants.vh"

module RegisterFile
#(
	// -1 to have MSB index ready
    parameter REG_ADDRS_BITS_I 	= `REG_ADDRS_BITS - 1,
    parameter PROC_BITS_I	 	= `PROC_BITS - 1,
    parameter DEBUG_BITS_I 		= (`PROC_BITS*`PROC_BITS) - 1
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
	output wire [DEBUG_BITS_I	 :0]	o_debug_regs
);

	localparam REG_COUNT = 2**(REG_ADDRS_BITS_I + 1);

	reg [PROC_BITS_I:0] registers [0:REG_COUNT-1];

	generate
	   genvar i;
	   for (i=0; i<32; i=i+1) begin
           localparam start_i = (i+1)*32-1;
           localparam end_i = i*32;
           assign o_debug_regs[start_i:end_i] = registers[i];
	   end
	endgenerate

	always@(posedge clk) begin
        //register 0 alwats has a value of 0
        registers[0] <= 0;

        //register 0 shouldn't be overwritten
		if (i_reg_write && (i_write_register != 0)) begin
			registers[i_write_register] <= i_write_data;
		end
	end

    always@(negedge clk) begin
        //check if write register is the same as read register so
        //we always return the updated register value except in the case of
        //reading register 0 so we don't return a value that is not 0
        if ((i_read_register_1 == i_write_register) &&
            (i_read_register_1 != 0)) begin
            o_read_data_1 <= i_write_data;
        end
        else begin
            o_read_data_1 <= registers[i_read_register_1];
        end

        //check if write register is the same as read register so
        //we always return the updated register value except in the case of
        //reading register 0 so we don't return a value that is not 0
        if ((i_read_register_1 == i_write_register) &&
            (i_read_register_1 != 0)) begin
            o_read_data_2 <= i_write_data;
        end
        else begin
            o_read_data_2 <= registers[i_read_register_2];
        end
    end

endmodule // RegisterFile
