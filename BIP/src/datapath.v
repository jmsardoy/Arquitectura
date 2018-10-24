

module Datapath
(
    input  clk,
    input  rst,
    input  [10 : 0] i_operand,
    input  [ 1 : 0] i_sel_a,
    input  i_sel_b,
    input  i_write_acc,
    input  i_operation,
    input  [15 : 0] i_mem_data,
    output [15 : 0] o_mem_data,
    output [10 : 0] o_mem_address
);

    reg  signed [15 : 0] accumulator;
    wire signed [15 : 0] op_result;
    wire signed [15 : 0] operand_ext;
    wire signed [15 : 0] multiplexor_b;
    
    
    //multiplexor b
    multiplexor_b = (i_sel_b) ? operand_ext : i_mem_data;
    
    //signal extention
    operand_ext = {{5{i_operand[10]}}, i_operand};

    //operation unit
    assign op_result = (i_operation) ? accumulator - multiplexor_b
                                     : accumulator + multiplexor_b;

    always@(negedge clk) begin
        if(!rst) begin
            accumulator <= 0;
        end
        else begin
            if (i_write_acc) begin
                case(i_sel_a)
                    0: accumulator <= i_mem_data;
                    1: accumulator <= operand_ext;
                    2: accumulator <= op_result;
                    default: accumulator <= accumulator;
                endcase
            end
        end
    end

    assign o_mem_address = i_operand;
    assign o_mem_data = accumulator;

endmodule
