`define FREQUENCY 50000000   // Frequency ay which we operate
`define BAUD_RATE 19200		// Selected baud rate

module BaudRateGenerator
    #(parameter FREQUENCY = `FREQUENCY,
      parameter BAUD_RATE = `BAUD_RATE)
                (input clk, 
                 input rst,
                 output reg out);

	localparam MAX_COUNT = (FREQUENCY / (BAUD_RATE * 16)) + 1;

	reg [7:0] count = 0;
	always@(posedge clk or negedge rst)
	begin 
	    if (!rst) out = 0;
        else begin
            count = count + 1;
            if(count == MAX_COUNT)
            begin
                out = ~out;
                count = 0;
            end
	    end
	end

endmodule
