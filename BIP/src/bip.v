
module BIP
(
    input clk,
    input rst,
    output [15 : 0] accumulator,
    output reg [7 : 0] inst_count,
    output done
);

always@(posedge clk) begin
    if(!rst) begin
        inst_count <= 0;
    end
    else begin
        if (!done) 
            inst_count <= inst_count+1;
    end
end

wire [10 : 0] program_address;
wire [15 : 0] instruction;
wire [10 : 0] operand;
wire [10 : 0] data_address;
wire [15 : 0] data_mem_in;
wire [15 : 0] data_mem_out;
wire [ 1 : 0] sel_a;
wire sel_b;
wire write_acc;
wire operation;
wire write_mem;
wire read_mem;

Control control_u
(
    .clk(clk),
    .rst(rst),
    .i_instruction(instruction),
    .o_prog_address(program_address),
    .o_operand(operand),
    .o_sel_a(sel_a),
    .o_sel_b(sel_b),
    .o_write_acc(write_acc),
    .o_operation(operation),
    .o_write_mem(write_mem),
    .o_read_mem(read_mem),
    .o_done(done)
);


ProgramMemory prog_mem_u
(
    .clk(clk),
    .i_address(program_address),
    .o_data(instruction)
);

DataMemory data_mem_u
(
    .clk(clk),
    .read(read_mem),
    .write(write_mem),
    .i_address(operand),
    .i_data(data_mem_in),
    .o_data(data_mem_out)
);

Datapath datapath_u
(
    .clk(clk),
    .rst(rst),
    .i_operand(operand),
    .i_sel_a(sel_a),
    .i_sel_b(sel_b),
    .i_write_acc(write_acc),
    .i_operation(operation),
    .i_mem_data(data_mem_out),
    .o_mem_data(data_mem_in),
    .o_mem_address(data_address)
);

assign accumulator = data_mem_in;

endmodule
