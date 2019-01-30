`timescale 1ns / 1ps


module tb_Control();

    reg  [5:0] opcode;
    wire       RegDst;
    wire [1:0] ALUOp;
    wire       ALUSrc;
    wire       Branch;
    wire       MemRead;
    wire       MemWrite;
    wire       RegWrite;
    wire       MemtoReg;

    localparam RFORMAT = 'b000000;
    localparam LW      = 'b100011;
    localparam SW      = 'b101011;
    localparam BEQ     = 'b000100;

    initial begin
        opcode = RFORMAT;
        #20
        opcode = LW;
        #20
        opcode = SW;
        #20
        opcode = BEQ;
    end

    Control Control_u(
        .i_opcode(opcode),
        .o_RegDst(RegDst),
        .o_ALUOp(ALUOp),
        .o_ALUSrc(ALUSrc),
        .o_Branch(Branch),
        .o_MemRead(MemRead),
        .o_MemWrite(MemWrite),
        .o_RegWrite(RegWrite),
        .o_MemtoReg(MemtoReg)
    );



endmodule
