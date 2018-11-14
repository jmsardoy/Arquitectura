

module TBProgramMemory();

    reg clk;
    reg [4:0] address;
    wire [7:0] data;

    initial begin
        clk = 0;
        address = 0;
        #2 address = 1;
        #2 address = 2;
        #2 address = 3;

    end

    always #1 clk = ~clk;

    ProgramMemory 
    #(.ADDRESS_BITS(5),
      .DATA_BITS(8)
      )
    prog_mem_u 
    (.clk(clk),
     .i_address(address),
     .o_data(data));

endmodule
