`include "memory_defs.vh"

module Datapath
#(
    parameter ADDRESS_BITS = `ADDRESS_BITS,
    parameter DATA_BITS = `DATA_BITS
)
(
    input  clk,
    input  rst,
    input  [ADDRESS_BITS - 1 : 0] i_operand,
    input  [ 1 : 0] i_sel_a,
    input  i_sel_b,
    input  i_write_acc,
    input  i_operation,
    input  [DATA_BITS - 1 : 0] i_mem_data,
    output [DATA_BITS - 1 : 0] o_mem_data,
    output [ADDRESS_BITS - 1 : 0] o_mem_address
);

    reg  signed [DATA_BITS - 1 : 0] accumulator;
    wire signed [DATA_BITS - 1 : 0] op_result;
    wire signed [DATA_BITS - 1 : 0] operand_ext;
    wire signed [DATA_BITS - 1 : 0] multiplexor_b;


    //multiplexor b
    assign multiplexor_b = (i_sel_b) ? operand_ext : i_mem_data;

    //signal extention
    assign operand_ext = {{(DATA_BITS - ADDRESS_BITS){i_operand[ADDRESS_BITS - 1]}}, i_operand};

    //operation unit
    assign op_result = (i_operation) ? accumulator - multiplexor_b
                                     : accumulator + multiplexor_b;

    always@(posedge clk) begin
        if(!rst) begin
            accumulator <= 0;
        end
        else begin
            if (i_write_acc) begin
                case(i_sel_a)
                    0: accumulator <= i_mem_data;
                    1: accumulator <= operand_ext;
                    2: accumulator <= op_result;
                    default: accumulator <= 0;
                endcase
            end
            else begin
                accumulator <= accumulator;
            end
        end
    end

    assign o_mem_address = i_operand;
    assign o_mem_data = accumulator;

endmodule
