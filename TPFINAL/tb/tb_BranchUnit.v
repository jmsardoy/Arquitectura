`timescale 1ns/1ps

`include "constants.vh"


module tb_BranchUnit();

    localparam OPCODE_BITS = `OPCODE_BITS;
    localparam PROC_BITS   = `PROC_BITS;
    localparam PC_BITS     = `PC_BITS;
    localparam FUNCT_BITS  = `FUNCT_BITS;

    reg branch_enable;
    reg [OPCODE_BITS - 1 : 0] opcode;
    reg [FUNCT_BITS - 1  : 0] funct;
    reg [PC_BITS -1      : 0] pc_next;
    reg [PROC_BITS - 1   : 0] immediate;
    reg [PROC_BITS - 1   : 0] i_jump_address;
    reg [PROC_BITS - 1   : 0] data_rs;
    reg [PROC_BITS - 1   : 0] data_rt;

    wire taken;
    wire pc_to_reg;
    wire [PC_BITS - 1 : 0] o_jump_address;
    wire [PC_BITS - 1 : 0] pc_return;
    wire pc_reg_sel;

    localparam BEQ     = 'b000100;
    localparam BNE     = 'b000101;
    localparam J       = 'b000010;
    localparam JAL     = 'b000011;
    localparam JR_JALR = 'b000000;

    initial begin
        branch_enable = 1;
        opcode = 0;
        funct = 0;
        pc_next = 0;
        immediate = 0;
        i_jump_address = 0;
        data_rs = 0;
        data_rt = 0;

        //test BEQ taken
        opcode = BEQ;
        pc_next = 5;
        immediate = 8;
        data_rs = 5;
        data_rt = 5;
        #20
    
        //test BEQ not taken
        opcode = BEQ;
        pc_next = 5;
        immediate = 8;
        data_rs = 5;
        data_rt = 7;
        #20

        //test J
        opcode = J;
        i_jump_address = 117;
        #20

        //test JAL
        opcode = JAL;
        i_jump_address = 95;
        #20

        //test JR
        opcode = JR_JALR;
        funct = 'b001000;
        data_rs = 36;
        #20

        //test JALR
        opcode = JR_JALR;
        funct = 'b001001;
        data_rs = 47;
        #20

        //test RTYPE NON JUMP
        opcode = JR_JALR;
        funct = 'b000000;

        ;
    end

    BranchUnit branch_unit_u(
        .i_branch_enable(branch_enable),
        .i_opcode(opcode),
        .i_funct(funct),
        .i_pc_next(pc_next),
        .i_immediate(immediate),
        .i_jump_address(i_jump_address),
        .i_data_rs(data_rs),
        .i_data_rt(data_rt),
        .o_taken(taken),
        .o_pc_to_reg(pc_to_reg),
        .o_jump_address(o_jump_address),
        .o_pc_return(pc_return),
        .o_pc_reg_sel(pc_reg_sel)
    );
    
endmodule
