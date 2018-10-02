//`define FREQUENCY 50000000   // Frequency at which we operate
`define  FREQUENCY 100000000   // Frequency at which we operate
`define BAUD_RATE 19200		// Selected baud rate

module BaudRateGenerator
    #(parameter FREQUENCY = `FREQUENCY,
      parameter BAUD_RATE = `BAUD_RATE)
                (input clk, 
                 input rst,
                 output reg out);

	localparam MAX_COUNT = (FREQUENCY / (BAUD_RATE * 16));
    localparam COUNT_NBITS = $clog2(MAX_COUNT);

	reg [COUNT_NBITS : 0] count;
	always@(posedge clk or negedge rst)
	begin 
	    if (!rst) begin
            out <= 0;
            count <= 0;
        end 
        else begin
            if(count == MAX_COUNT)
            begin
                out <= 1;
                count <= 0;
            end
            else begin
                out <= 0;
                count <= count + 1;
            end
	    end
	end

endmodule
