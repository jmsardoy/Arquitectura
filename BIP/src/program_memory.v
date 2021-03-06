`include "memory_defs.vh"

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

    `define INSTRUCTION(MNEMONIC, OPCODE) localparam MNEMONIC = OPCODE;
    `include "instructions.vh"

    always@(posedge clk) begin
        if(!rst) begin

            `define DATA_MEMORY(ADDRESS, MNEMONIC, ARGS) mem[ADDRESS] <= {MNEMONIC, ARGS};
            `include "program.vh"

            mem[`LAST_ADDRESS] <= {16{1'b1}}; //para evitar warning que elimina bits de o_data
            o_data  <= {16{1'b1}};
        end
        else begin
            o_data <= mem[i_address];
        end
    end

endmodule
