`define FREQUENCY 100000000   // Frequency ay which we operate
`define BAUD_RATE 9600		// Selected baud rate

module BaudRateGenerator
    #(parameter FREQUENCY = `FREQUENCY,
      parameter BAUD_RATE = `BAUD_RATE)
                (input clk, 
                 input rst,
                 output out);

	localparam MAX_COUNT = FREQUENCY / BAUD_RATE;

	integer count = 0;
	always@(posedge clk)
	begin
		count = count + 1;
		if(count == MAX_COUNT)
		begin
			out = ~out;
			count = 0;
		end
	end

endmodule
