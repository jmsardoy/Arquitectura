`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   17:55:22 10/06/2016
// Design Name:   BaudRateGenerator
// Module Name:   /home/juanso/dev/xilinx/UART_Arquitectura/testBaudRate.v
// Project Name:  UART
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: BaudRateGenerator
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module testBaudRate;

	// Inputs
	reg clk;
	reg rst;
	integer counter;

	// Outputs
	wire out;

	// Instantiate the Unit Under Test (UUT)
	BaudRateGenerator uut (
		.clk(clk), 
		.out(out),
		.rst(rst)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		rst = 0;
		counter = 0;

		// Wait 100 ns for global reset to finish
		#1;
		rst = 1;
        
		// Add stimulus here

	end
	always
	begin
		#1; 
		clk = 0;
		#1; 
		clk = 1;
		counter = counter + 1;
	end
endmodule

