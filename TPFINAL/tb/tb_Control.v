`timescale 1ns / 1ps

`include "constants.vh"

module tb_Control();

    reg  [5:0] opcode;
    reg  [5:0] funct;
    reg        control_mux;
    wire       RegDst;
    wire       RegWrite;
    wire       MemRead;
    wire       MemWrite;
    wire       MemtoReg;
    wire [3:0] ALUOp;
    wire       ALUSrc;
    wire       Shamt;
    wire [2:0] ls_filter_op;

    initial begin
        control_mux = 1;
        opcode = `ADD_OP;
        funct = `ADD_FUNCT;
        #20
        opcode = `SUB_OP;
        funct = `SUB_FUNCT;
        #20
        opcode = `AND_OP;
        funct = `AND_FUNCT;
        #20
        opcode = `OR_OP;
        funct = `OR_FUNCT;
        #20
        opcode = `XOR_OP;
        funct = `XOR_FUNCT;
        #20
        opcode = `NOR_OP;
        funct = `NOR_FUNCT;
        #20
        opcode = `SLT_OP;
        funct = `SLT_FUNCT;
        #20
        opcode = `SLL_OP;
        funct = `SLL_FUNCT;
        #20
        opcode = `SRL_OP;
        funct = `SRL_FUNCT;
        #20
        opcode = `SRA_OP;
        funct = `SRA_FUNCT;
        #20
        opcode = `SLLV_OP;
        funct = `SLLV_FUNCT;
        #20
        opcode = `SRLV_OP;
        funct = `SRLV_FUNCT;
        #20
        opcode = `SRAV_OP;
        funct = `SRAV_FUNCT;
        #20
        opcode = `ADDU_OP;
        funct = `ADDU_FUNCT;
        #20
        opcode = `SUBU_OP;
        funct = `SUBU_FUNCT;
        #20

        //break with control_mux
        control_mux = 0;
        #20

        //LOADS
        control_mux = 1;
        funct = 0;
        opcode = `LB_OP;
        #20
        opcode = `LH_OP;
        #20
        opcode = `LW_OP;
        #20
        opcode = `LBU_OP;
        #20
        opcode = `LHU_OP;
        #20

        //break with control_mux
        control_mux = 0;
        #20

        //STORES
        control_mux = 1;
        opcode = `SB_OP;
        #20
        opcode = `SH_OP;
        #20
        opcode = `SW_OP;
        #20

        //break with control_mux
        control_mux = 0;
        #20

        //INMED
        control_mux = 1;
        opcode = `ADDI_OP;
        #20
        opcode = `ANDI_OP;
        #20
        opcode = `ORI_OP;
        #20
        opcode = `XORI_OP;
        #20
        opcode = `LUI_OP;
        #20
        opcode = `SLTI_OP;
        #20

        //break with control_mux
        control_mux = 0;
        #20

        //BRANCHS
        control_mux = 1;
        opcode = `BEQ_OP;
        #20
        opcode = `BNE_OP;
        #20

        //break with control_mux
        control_mux = 0;
        #20

        //J-JAL
        control_mux = 1;
        opcode = `J_OP;
        #20
        opcode = `JAL_OP;
        #20

        //break with control_mux
        control_mux = 0;
        #20

        //JR-JARL
        control_mux = 1;
        opcode = `JR_OP;
        funct = `JR_FUNCT;
        #20
        opcode = `JARL_OP;
        funct = `JARL_FUNCT;
        #20



        //break with control_mux
        control_mux = 0;
        #20;

    end

    Control Control_u(
        .i_opcode(opcode),
        .i_funct(funct),
        .i_control_mux(control_mux),
        .o_RegDst(RegDst),
        .o_RegWrite(RegWrite),
        .o_MemRead(MemRead),
        .o_MemWrite(MemWrite),
        .o_MemtoReg(MemtoReg),
        .o_ALUOp(ALUOp),
        .o_ALUSrc(ALUSrc),
        .o_Shamt(Shamt),
        .o_ls_filter_op(ls_filter_op)
    );



endmodule
