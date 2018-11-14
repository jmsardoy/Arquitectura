`include "memory_defs.vh"

module Control
#(
    parameter ADDRESS_BITS = `ADDRESS_BITS,
    parameter DATA_BITS = `DATA_BITS
)
(
    input clk,
    input rst,
    input [DATA_BITS - 1:0] i_instruction,
    output [ADDRESS_BITS - 1 : 0] o_prog_address,
    output [ADDRESS_BITS - 1 : 0] o_operand,
    output [ 1 : 0] o_sel_a,
    output o_sel_b,
    output o_write_acc,
    output o_operation,
    output o_write_mem,
    output o_read_mem,
    output o_done
);

    wire enable_pc;

    wire [4 : 0] opcode = i_instruction[DATA_BITS - 1:ADDRESS_BITS];
    assign o_operand = i_instruction[ADDRESS_BITS - 1:0];

    reg [10 : 0] program_counter;

    always@(negedge clk) begin
        if (!rst) begin
            program_counter <= 0;
        end
        else begin
            if (enable_pc) begin
                program_counter <= program_counter+1;
            end
        end
    end

    assign o_prog_address = program_counter;

    InstructionDecoder ID_u
    (
        .opcode(opcode),
        .o_enable_pc(enable_pc),
        .o_sel_a(o_sel_a),
        .o_sel_b(o_sel_b),
        .o_write_acc(o_write_acc),
        .o_operation(o_operation),
        .o_write_mem(o_write_mem),
        .o_read_mem(o_read_mem),
        .bip_done(o_done)
    );


endmodule

