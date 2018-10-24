

module TBDataMemory();

    reg clk;
    reg read;
    reg write;
    reg [4:0] address;
    reg [7:0] i_data;
    wire [7:0] o_data;

    initial begin
        clk = 0;
        address = 0;
        read = 0;
        write = 0;

        #2
        i_data = 8;
        write = 1;
        
        #2 write = 0;

        #2 read = 1;
        #2 read = 0;

    end

    always #1 clk = ~clk;

    DataMemory
    #(.ADDRESS_BITS(5),
      .DATA_BITS(8)
      )
    data_mem_u 
    (.clk(clk),
     .read(read),
     .write(write),
     .i_address(address),
     .i_data(i_data),
     .o_data(o_data));

endmodule
