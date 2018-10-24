`define ADDRESS_BITS 11
`define DATA_BITS 16

module ProgramMemory
#(
    parameter ADDRESS_BITS = `ADDRESS_BITS,
    parameter DATA_BITS = `DATA_BITS
)
(
	input clk,
    input rst,
	input wire [ADDRESS_BITS-1:0] i_address,
	output reg [DATA_BITS-1:0] o_data
);
	
	localparam MEM_SIZE = 2**ADDRESS_BITS;

	reg [DATA_BITS-1:0] mem [0:MEM_SIZE-1];


    localparam HLT  = 'b00000;
    localparam STO  = 'b00001;
    localparam LD   = 'b00010;
    localparam LDI  = 'b00011;
    localparam ADD  = 'b00100;
    localparam ADDI = 'b00101;
    localparam SUB  = 'b00110;
    localparam SUBI = 'b00111;

	
    always@(negedge clk) begin
        if(!rst) begin
            mem[0]  <= { LDI  , -11'd4};
            mem[1]  <= { STO  , 11'd1};
            mem[2]  <= { LDI  , 11'd2};
            mem[3]  <= { ADD  , 11'd1};
            mem[4]  <= { STO  , 11'd2};
            mem[5]  <= { LDI  , 11'd123};
            mem[6]  <= { ADDI , 11'd7 };
            mem[7]  <= { LD   , 11'd2};
            mem[8]  <= { ADDI , 11'd4};
            mem[9]  <= { SUBI , 11'd50};
            mem[10] <= { SUB  , 11'd1};
            mem[11] <= { HLT  , 11'd0};

            mem[12] <= {16{1'b1}}; //para evitar warning que elimina bits de o_data

        end
        else begin
            o_data <= mem[i_address];
        end
    end

endmodule
