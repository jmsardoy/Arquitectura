`timescale 1ns / 1ps

`include "constants.vh"

module tb_Execution();

    localparam PC_BITS          = `PC_BITS;
    localparam INSTRUCTION_BITS = `INSTRUCTION_BITS;
    localparam PROC_BITS        = `PROC_BITS;
    localparam REG_ADDRS_BITS   = `REG_ADDRS_BITS;
    localparam OPCODE_BITS      = `OPCODE_BITS;

    //inputs directly to execution
    reg [PC_BITS - 1 : 0] PCNext;
    reg [OPCODE_BITS - 1 : 0] opcode;
    reg [PROC_BITS - 1 : 0] read_data_1;
    reg [PROC_BITS - 1 : 0] read_data_2;
    reg [PROC_BITS - 1 : 0] immediate_data_ext;
    reg [PC_BITS - 1 : 0] jump_address;
    reg [REG_ADDRS_BITS - 1 : 0] rs;
    reg [REG_ADDRS_BITS - 1 : 0] rt;
    reg [REG_ADDRS_BITS - 1 : 0] rd;

    //input from hazard detector to branch unit
    reg branch_enable;

    //inputs for fowarding
    reg [PROC_BITS - 1 : 0] ex_mem_data;
    reg [PROC_BITS - 1 : 0] mem_wb_data;
    reg [REG_ADDRS_BITS - 1 : 0] ex_mem_rd;
    reg [REG_ADDRS_BITS - 1 : 0] mem_wb_rd;
    reg ex_mem_RegWrite;
    reg mem_wb_RegWrite;


    //outputs from execution
    wire [PROC_BITS - 1 : 0] alu_result;
    wire [PROC_BITS - 1 : 0] rt_data;
    wire [REG_ADDRS_BITS - 1 : 0] o_rd;

    //output from branch unit
    wire taken;
    wire pc_to_reg;
    wire [PC_BITS - 1 : 0] o_jump_address;
    wire [PC_BITS - 1 : 0] pc_return;

    //control outputs
    wire o_RegWrite;
    wire o_MemRead;
    wire o_MemWrite;
    wire o_MemtoReg;
    wire [2:0] o_ls_filter_op;


    //signal for control unit
    wire [5:0] funct = immediate_data_ext[5:0];
    reg control_mux;

    //wire for connection between Control and Execution
    wire       i_RegDst;
    wire       i_RegWrite;
    wire       i_MemRead;
    wire       i_MemWrite;
    wire       i_MemtoReg;
    wire [3:0] i_ALUOp;
    wire       i_ALUSrc;
    wire       i_Shamt;
    wire [2:0] i_ls_filter_op;

    localparam LOAD    = 3'b100;
    localparam STORE   = 3'b101;
    localparam INMED   = 3'b001;
    localparam OTHER   = 3'b000;

    localparam FUNCT_ADD  = 6'b100000;
    localparam FUNCT_ADDU = 6'b100001;
    localparam FUNCT_SUB  = 6'b100010;
    localparam FUNCT_SUBU = 6'b100011;
    localparam FUNCT_AND  = 6'b100100;
    localparam FUNCT_OR   = 6'b100101;
    localparam FUNCT_XOR  = 6'b100110;
    localparam FUNCT_NOR  = 6'b100111;
    localparam FUNCT_SLT  = 6'b101010;
    localparam FUNCT_SLL  = 6'b000000;
    localparam FUNCT_SRL  = 6'b000010;
    localparam FUNCT_SRA  = 6'b000011;
    localparam FUNCT_SLLV = 6'b000100;
    localparam FUNCT_SRLV = 6'b000110;
    localparam FUNCT_SRAV = 6'b000111;

    localparam INMED_ADD  = 3'b000;
    localparam INMED_AND  = 3'b100;
    localparam INMED_OR   = 3'b101;
    localparam INMED_XOR  = 3'b110;
    localparam INMED_LUI  = 3'b111;
    localparam INMED_SLT  = 3'b010;

    localparam BEQ     = 6'b000100;
    localparam BNE     = 6'b000101;
    localparam J       = 6'b000010;
    localparam JAL     = 6'b000011;
    localparam JR_JALR = 6'b000000;


    initial begin
        //control_mux and branch_enable is always set to 1 during the whole test cause 
        //where not testing hazard detection
        //actually they are the same signal
        control_mux = 1;
        branch_enable = 1;

        //we set PCNext and jump_address to 0 cause where not testing
        //branch right now
        PCNext = 0;
        jump_address = 0;

        //we set ex_mem_RegWrite and mem_wb_RegWrite to 0 cause where not
        //testing fowarding right now
        rs = 0;
        ex_mem_data = 0;
        mem_wb_data = 0;
        ex_mem_rd = 0;
        mem_wb_rd = 0;
        ex_mem_RegWrite = 0;
        mem_wb_RegWrite = 0;

        //rs and rt are set differently to test RegDst mux and check o_rd
        rt = 5;
        rd = 9;
        
        //RTYPE test

        //During RTYPE instructions we olny set opcode, immediate_data_ext
        //, read_data_1 and read_data_2
        //we check for alu_result and o_rd

        //test ADD;
        opcode = 0;
        immediate_data_ext = { {26{1'b0}} , FUNCT_ADD};
        read_data_1 = 5;
        read_data_2 = 10;
        #20 if (alu_result     != 15) $finish;
            if (o_RegWrite     != 1) $finish;
            if (o_MemRead      != 0) $finish;
            if (o_MemWrite     != 0) $finish;
            if (o_MemtoReg     != 0) $finish;
            if (o_ls_filter_op != 0) $finish;
            if (o_rd           != 9) $finish;
            if (taken          != 0) $finish;
            if (pc_to_reg      != 0) $finish;
            if (o_jump_address != 0) $finish;
            if (pc_return      != 0) $finish;
        #20

        //test ADDU (same as ADD);
        opcode = 0;
        immediate_data_ext = { {26{1'b0}} , FUNCT_ADDU};
        read_data_1 = -2;
        read_data_2 = 10;
        #20 if (alu_result != 8) $finish;
            if (o_RegWrite     != 1) $finish;
            if (o_MemRead      != 0) $finish;
            if (o_MemWrite     != 0) $finish;
            if (o_MemtoReg     != 0) $finish;
            if (o_ls_filter_op != 0) $finish;
            if (o_rd           != 9) $finish;
            if (taken          != 0) $finish;
            if (pc_to_reg      != 0) $finish;
            if (o_jump_address != 0) $finish;
            if (pc_return      != 0) $finish;
        #20
        

        //test SUB;
        opcode = 0;
        immediate_data_ext = { {26{1'b0}} , FUNCT_SUB};
        read_data_1 = 27;
        read_data_2 = 7;
        #20 if (alu_result != 20) $finish;
        #20

        //test SUBU (same as SUB);
        opcode = 0;
        immediate_data_ext = { {26{1'b0}} , FUNCT_SUBU};
        read_data_1 = -2;
        read_data_2 = 10;
        #20 if (alu_result != -12) $finish;
            if (o_RegWrite     != 1) $finish;
            if (o_MemRead      != 0) $finish;
            if (o_MemWrite     != 0) $finish;
            if (o_MemtoReg     != 0) $finish;
            if (o_ls_filter_op != 0) $finish;
            if (o_rd           != 9) $finish;
            if (taken          != 0) $finish;
            if (pc_to_reg      != 0) $finish;
            if (o_jump_address != 0) $finish;
            if (pc_return      != 0) $finish;
        #20

        //test AND
        opcode = 0;
        immediate_data_ext = { {26{1'b0}} , FUNCT_AND};
        read_data_1 =         'b00000010001000001000000000010000;
        read_data_2 =         'b00000010000000001000001000010000;
        #20 if (alu_result != 'b00000010000000001000000000010000) $finish;
            if (o_RegWrite     != 1) $finish;
            if (o_MemRead      != 0) $finish;
            if (o_MemWrite     != 0) $finish;
            if (o_MemtoReg     != 0) $finish;
            if (o_ls_filter_op != 0) $finish;
            if (o_rd           != 9) $finish;
            if (taken          != 0) $finish;
            if (pc_to_reg      != 0) $finish;
            if (o_jump_address != 0) $finish;
            if (pc_return      != 0) $finish;
        #20

        //test OR
        opcode = 0;
        immediate_data_ext = { {26{1'b0}} , FUNCT_OR};
        read_data_1 =         'b00000010001010001000000000010000;
        read_data_2 =         'b00000010000000001000001000010010;
        #20 if (alu_result != 'b00000010001010001000001000010010) $finish;
            if (o_RegWrite     != 1) $finish;
            if (o_MemRead      != 0) $finish;
            if (o_MemWrite     != 0) $finish;
            if (o_MemtoReg     != 0) $finish;
            if (o_ls_filter_op != 0) $finish;
            if (o_rd           != 9) $finish;
            if (taken          != 0) $finish;
            if (pc_to_reg      != 0) $finish;
            if (o_jump_address != 0) $finish;
            if (pc_return      != 0) $finish;
        #20

        //test XOR
        opcode = 0;
        immediate_data_ext = { {26{1'b0}} , FUNCT_XOR};
        read_data_1 =         'b00000010001010101000000000010000;
        read_data_2 =         'b00000010000000101000001000010010;
        #20 if (alu_result != 'b00000000001010000000001000000010) $finish;
            if (o_RegWrite     != 1) $finish;
            if (o_MemRead      != 0) $finish;
            if (o_MemWrite     != 0) $finish;
            if (o_MemtoReg     != 0) $finish;
            if (o_ls_filter_op != 0) $finish;
            if (o_rd           != 9) $finish;
            if (taken          != 0) $finish;
            if (pc_to_reg      != 0) $finish;
            if (o_jump_address != 0) $finish;
            if (pc_return      != 0) $finish;
        #20

        //test NOR
        opcode = 0;
        immediate_data_ext = { {26{1'b0}} , FUNCT_NOR};
        read_data_1 =         'b00000010001010001000000000010000;
        read_data_2 =         'b00000010000000001000001000010010;
        #20 if (alu_result != 'b11111101110101110111110111101101) $finish;
            if (o_RegWrite     != 1) $finish;
            if (o_MemRead      != 0) $finish;
            if (o_MemWrite     != 0) $finish;
            if (o_MemtoReg     != 0) $finish;
            if (o_ls_filter_op != 0) $finish;
            if (o_rd           != 9) $finish;
            if (taken          != 0) $finish;
            if (pc_to_reg      != 0) $finish;
            if (o_jump_address != 0) $finish;
            if (pc_return      != 0) $finish;
        #20

        //test SLT (positive result)
        opcode = 0;
        immediate_data_ext = { {26{1'b0}} , FUNCT_SLT};
        read_data_1 =         5;
        read_data_2 =         9;
        #20 if (alu_result != 1) $finish;
            if (o_RegWrite     != 1) $finish;
            if (o_MemRead      != 0) $finish;
            if (o_MemWrite     != 0) $finish;
            if (o_MemtoReg     != 0) $finish;
            if (o_ls_filter_op != 0) $finish;
            if (o_rd           != 9) $finish;
            if (taken          != 0) $finish;
            if (pc_to_reg      != 0) $finish;
            if (o_jump_address != 0) $finish;
            if (pc_return      != 0) $finish;
        #20

        //test SLT (positive result)
        opcode = 0;
        immediate_data_ext = { {26{1'b0}} , FUNCT_SLT};
        read_data_1 =         -5;
        read_data_2 =         -9;
        #20 if (alu_result != 0) $finish;
            if (o_RegWrite     != 1) $finish;
            if (o_MemRead      != 0) $finish;
            if (o_MemWrite     != 0) $finish;
            if (o_MemtoReg     != 0) $finish;
            if (o_ls_filter_op != 0) $finish;
            if (o_rd           != 9) $finish;
            if (taken          != 0) $finish;
            if (pc_to_reg      != 0) $finish;
            if (o_jump_address != 0) $finish;
            if (pc_return      != 0) $finish;
        #20

        //test SLL
        opcode = 0;
        immediate_data_ext = { {21{1'b0}}, 5'b00100, FUNCT_SLL};
        read_data_1 =         'b00000010001010001000000000010000; //X
        read_data_2 =         'b00000010000000001000001000010010; 
        #20 if (alu_result != 'b00100000000010000010000100100000) $finish;
            if (o_RegWrite     != 1) $finish;
            if (o_MemRead      != 0) $finish;
            if (o_MemWrite     != 0) $finish;
            if (o_MemtoReg     != 0) $finish;
            if (o_ls_filter_op != 0) $finish;
            if (o_rd           != 9) $finish;
            if (taken          != 0) $finish;
            if (pc_to_reg      != 0) $finish;
            if (o_jump_address != 0) $finish;
            if (pc_return      != 0) $finish;
        #20

        //test SRL
        opcode = 0;
        immediate_data_ext = { {21{1'b0}}, 5'b00011, FUNCT_SRL};
        read_data_1 =         'b00000010001010001000000000010000; //X
        read_data_2 =         'b10000010000000001000001000010010; 
        #20 if (alu_result != 'b00010000010000000001000001000010) $finish;
            if (o_RegWrite     != 1) $finish;
            if (o_MemRead      != 0) $finish;
            if (o_MemWrite     != 0) $finish;
            if (o_MemtoReg     != 0) $finish;
            if (o_ls_filter_op != 0) $finish;
            if (o_rd           != 9) $finish;
            if (taken          != 0) $finish;
            if (pc_to_reg      != 0) $finish;
            if (o_jump_address != 0) $finish;
            if (pc_return      != 0) $finish;
        #20

        //test SRA (positive)
        opcode = 0;
        immediate_data_ext = { {21{1'b0}}, 5'b00011, FUNCT_SRA};
        read_data_1 =         'b00000010001010001000000000010000; //X
        read_data_2 =         'b00000010000000001000001000010010; 
        #20 if (alu_result != 'b00000000010000000001000001000010) $finish;
            if (o_RegWrite     != 1) $finish;
            if (o_MemRead      != 0) $finish;
            if (o_MemWrite     != 0) $finish;
            if (o_MemtoReg     != 0) $finish;
            if (o_ls_filter_op != 0) $finish;
            if (o_rd           != 9) $finish;
            if (taken          != 0) $finish;
            if (pc_to_reg      != 0) $finish;
            if (o_jump_address != 0) $finish;
            if (pc_return      != 0) $finish;
        #20

        //test SRA (negative)
        opcode = 0;
        immediate_data_ext = { {21{1'b0}}, 5'b00011, FUNCT_SRA};
        read_data_1 =         'b00000010001010001000000000010000; //X
        read_data_2 =         'b10000010000000001000001000010010; 
        #20 if (alu_result != 'b11110000010000000001000001000010) $finish;
            if (o_RegWrite     != 1) $finish;
            if (o_MemRead      != 0) $finish;
            if (o_MemWrite     != 0) $finish;
            if (o_MemtoReg     != 0) $finish;
            if (o_ls_filter_op != 0) $finish;
            if (o_rd           != 9) $finish;
            if (taken          != 0) $finish;
            if (pc_to_reg      != 0) $finish;
            if (o_jump_address != 0) $finish;
            if (pc_return      != 0) $finish;
        #20

        //test SLLV
        opcode = 0;
        immediate_data_ext = { {26{1'b0}}, FUNCT_SLLV};
        read_data_1 =         8; //X
        read_data_2 =         'b10000010000000001000001000010010; 
        #20 if (alu_result != 'b00000000100000100001001000000000) $finish;
            if (o_RegWrite     != 1) $finish;
            if (o_MemRead      != 0) $finish;
            if (o_MemWrite     != 0) $finish;
            if (o_MemtoReg     != 0) $finish;
            if (o_ls_filter_op != 0) $finish;
            if (o_rd           != 9) $finish;
            if (taken          != 0) $finish;
            if (pc_to_reg      != 0) $finish;
            if (o_jump_address != 0) $finish;
            if (pc_return      != 0) $finish;
        #20

        //test SRLV
        opcode = 0;
        immediate_data_ext = { {26{1'b0}}, FUNCT_SRLV};
        read_data_1 =         8; //X
        read_data_2 =         'b10000010000000001000001000010010; 
        #20 if (alu_result != 'b00000000100000100000000010000010) $finish;
            if (o_RegWrite     != 1) $finish;
            if (o_MemRead      != 0) $finish;
            if (o_MemWrite     != 0) $finish;
            if (o_MemtoReg     != 0) $finish;
            if (o_ls_filter_op != 0) $finish;
            if (o_rd           != 9) $finish;
            if (taken          != 0) $finish;
            if (pc_to_reg      != 0) $finish;
            if (o_jump_address != 0) $finish;
            if (pc_return      != 0) $finish;
        #20

        //test SRAV (positive)
        opcode = 0;
        immediate_data_ext = { {26{1'b0}}, FUNCT_SRAV};
        read_data_1 =         6; //X
        read_data_2 =         'b00000010000000001000001000010010; 
        #20 if (alu_result != 'b00000000000010000000001000001000) $finish;
            if (o_RegWrite     != 1) $finish;
            if (o_MemRead      != 0) $finish;
            if (o_MemWrite     != 0) $finish;
            if (o_MemtoReg     != 0) $finish;
            if (o_ls_filter_op != 0) $finish;
            if (o_rd           != 9) $finish;
            if (taken          != 0) $finish;
            if (pc_to_reg      != 0) $finish;
            if (o_jump_address != 0) $finish;
            if (pc_return      != 0) $finish;
        #20

        //test SRAV (negative)
        opcode = 0;
        immediate_data_ext = { {26{1'b0}}, FUNCT_SRAV};
        read_data_1 =         6; //X
        read_data_2 =         'b10000010000000001000001000010010; 
        #20 if (alu_result != 'b11111110000010000000001000001000) $finish;
            if (o_RegWrite     != 1) $finish;
            if (o_MemRead      != 0) $finish;
            if (o_MemWrite     != 0) $finish;
            if (o_MemtoReg     != 0) $finish;
            if (o_ls_filter_op != 0) $finish;
            if (o_rd           != 9) $finish;
            if (taken          != 0) $finish;
            if (pc_to_reg      != 0) $finish;
            if (o_jump_address != 0) $finish;
            if (pc_return      != 0) $finish;
        #20


        //end test of all RTYPE instructions


        //test LOADS

        //LB
        opcode = {LOAD, 3'b000};
        read_data_1 = 25;
        rt = 16;
        immediate_data_ext = 160;
        #20 if (alu_result     != 185) $finish;
            if (o_RegWrite     != 1) $finish;
            if (o_MemRead      != 1) $finish;
            if (o_MemWrite     != 0) $finish;
            if (o_MemtoReg     != 1) $finish;
            if (o_ls_filter_op != 'b000) $finish;
            if (o_rd           != 16) $finish;
            if (taken          != 0) $finish;
            if (pc_to_reg      != 0) $finish;
            if (o_jump_address != 0) $finish;
            if (pc_return      != 0) $finish;
        #20

        //LH
        opcode = {LOAD, 3'b001};
        read_data_1 = 26;
        rt = 16;
        immediate_data_ext = 160;
        #20 if (alu_result     != 186) $finish;
            if (o_RegWrite     != 1) $finish;
            if (o_MemRead      != 1) $finish;
            if (o_MemWrite     != 0) $finish;
            if (o_MemtoReg     != 1) $finish;
            if (o_ls_filter_op != 'b001) $finish;
            if (o_rd           != 16) $finish;
            if (taken          != 0) $finish;
            if (pc_to_reg      != 0) $finish;
            if (o_jump_address != 0) $finish;
            if (pc_return      != 0) $finish;
        #20

        //LW
        opcode = {LOAD, 3'b011};
        read_data_1 = 27;
        rt = 16;
        immediate_data_ext = 160;
        #20 if (alu_result     != 187) $finish;
            if (o_RegWrite     != 1) $finish;
            if (o_MemRead      != 1) $finish;
            if (o_MemWrite     != 0) $finish;
            if (o_MemtoReg     != 1) $finish;
            if (o_ls_filter_op != 'b011) $finish;
            if (o_rd           != 16) $finish;
            if (taken          != 0) $finish;
            if (pc_to_reg      != 0) $finish;
            if (o_jump_address != 0) $finish;
            if (pc_return      != 0) $finish;
        #20

        //LBU
        opcode = {LOAD, 3'b100};
        read_data_1 = 28;
        rt = 16;
        immediate_data_ext = 160;
        #20 if (alu_result     != 188) $finish;
            if (o_RegWrite     != 1) $finish;
            if (o_MemRead      != 1) $finish;
            if (o_MemWrite     != 0) $finish;
            if (o_MemtoReg     != 1) $finish;
            if (o_ls_filter_op != 'b100) $finish;
            if (o_rd           != 16) $finish;
            if (taken          != 0) $finish;
            if (pc_to_reg      != 0) $finish;
            if (o_jump_address != 0) $finish;
            if (pc_return      != 0) $finish;
        #20

        //LHU
        opcode = {LOAD, 3'b101};
        read_data_1 = 29;
        rt = 16;
        immediate_data_ext = 160;
        #20 if (alu_result     != 189) $finish;
            if (o_RegWrite     != 1) $finish;
            if (o_MemRead      != 1) $finish;
            if (o_MemWrite     != 0) $finish;
            if (o_MemtoReg     != 1) $finish;
            if (o_ls_filter_op != 'b101) $finish;
            if (o_rd           != 16) $finish;
            if (taken          != 0) $finish;
            if (pc_to_reg      != 0) $finish;
            if (o_jump_address != 0) $finish;
            if (pc_return      != 0) $finish;
        #20

        //test STORES

        //SB
        opcode = {STORE, 3'b000};
        read_data_1 = 100;
        rt = 25;
        immediate_data_ext = 120;
        #20 if (alu_result     != 220) $finish;
            if (o_RegWrite     != 0) $finish;
            if (o_MemRead      != 0) $finish;
            if (o_MemWrite     != 1) $finish;
            if (o_MemtoReg     != 0) $finish;
            if (o_ls_filter_op != 'b000) $finish;
            if (o_rd           != 25) $finish;
            if (taken          != 0) $finish;
            if (pc_to_reg      != 0) $finish;
            if (o_jump_address != 0) $finish;
            if (pc_return      != 0) $finish;
        #20

        //SH
        opcode = {STORE, 3'b001};
        read_data_1 = 100;
        rt = 25;
        immediate_data_ext = -20;
        #20 if (alu_result     != 80) $finish;
            if (o_RegWrite     != 0) $finish;
            if (o_MemRead      != 0) $finish;
            if (o_MemWrite     != 1) $finish;
            if (o_MemtoReg     != 0) $finish;
            if (o_ls_filter_op != 'b001) $finish;
            if (o_rd           != 25) $finish;
            if (taken          != 0) $finish;
            if (pc_to_reg      != 0) $finish;
            if (o_jump_address != 0) $finish;
            if (pc_return      != 0) $finish;
        #20

        //SW
        opcode = {STORE, 3'b011};
        read_data_1 = 100;
        rt = 25;
        immediate_data_ext = -40;
        #20 if (alu_result     != 60) $finish;
            if (o_RegWrite     != 0) $finish;
            if (o_MemRead      != 0) $finish;
            if (o_MemWrite     != 1) $finish;
            if (o_MemtoReg     != 0) $finish;
            if (o_ls_filter_op != 'b011) $finish;
            if (o_rd           != 25) $finish;
            if (taken          != 0) $finish;
            if (pc_to_reg      != 0) $finish;
            if (o_jump_address != 0) $finish;
            if (pc_return      != 0) $finish;
        #20


        //test immediates

        //ADDI
        opcode = {INMED, INMED_ADD};
        read_data_1 = 50;
        rt = 18;
        immediate_data_ext = -4;
        #20 if (alu_result     != 46) $finish;
            if (o_RegWrite     != 1) $finish;
            if (o_MemRead      != 0) $finish;
            if (o_MemWrite     != 0) $finish;
            if (o_MemtoReg     != 0) $finish;
            if (o_ls_filter_op != 0) $finish;
            if (o_rd           != 18) $finish;
            if (taken          != 0) $finish;
            if (pc_to_reg      != 0) $finish;
            if (o_jump_address != 0) $finish;
            if (pc_return      != 0) $finish;
        #20

        //ANDI
        opcode = {INMED, INMED_AND};
        rt = 18;
        read_data_1 =             'b01001001000010000010011001010000;
        immediate_data_ext =      'b00000000000000000111000101010000;
        #20 if (alu_result     != 'b00000000000000000010000001010000) $finish;
            if (o_RegWrite     != 1) $finish;
            if (o_MemRead      != 0) $finish;
            if (o_MemWrite     != 0) $finish;
            if (o_MemtoReg     != 0) $finish;
            if (o_ls_filter_op != 'b100) $finish;
            if (o_rd           != 18) $finish;
            if (taken          != 0) $finish;
            if (pc_to_reg      != 0) $finish;
            if (o_jump_address != 0) $finish;
            if (pc_return      != 0) $finish;
        #20

        //ORI
        opcode = {INMED, INMED_OR};
        rt = 18;
        read_data_1 =             'b01001001000010000010011001010000;
        immediate_data_ext =      'b00000000000000000111000101010000;
        #20 if (alu_result     != 'b01001001000010000111011101010000) $finish;
            if (o_RegWrite     != 1) $finish;
            if (o_MemRead      != 0) $finish;
            if (o_MemWrite     != 0) $finish;
            if (o_MemtoReg     != 0) $finish;
            if (o_ls_filter_op != 'b101) $finish;
            if (o_rd           != 18) $finish;
            if (taken          != 0) $finish;
            if (pc_to_reg      != 0) $finish;
            if (o_jump_address != 0) $finish;
            if (pc_return      != 0) $finish;
        #20

        //XOR
        opcode = {INMED, INMED_XOR};
        rt = 18;
        read_data_1 =             'b01001001000010000010011001010000;
        immediate_data_ext =      'b00000000000000000111000101010000;
        #20 if (alu_result     != 'b01001001000010000101011100000000) $finish;
            if (o_RegWrite     != 1) $finish;
            if (o_MemRead      != 0) $finish;
            if (o_MemWrite     != 0) $finish;
            if (o_MemtoReg     != 0) $finish;
            if (o_ls_filter_op != 'b110) $finish;
            if (o_rd           != 18) $finish;
            if (taken          != 0) $finish;
            if (pc_to_reg      != 0) $finish;
            if (o_jump_address != 0) $finish;
            if (pc_return      != 0) $finish;
        #20

        //LUI
        opcode = {INMED, INMED_LUI};
        rt = 18;
        read_data_1 =             'b01001001000010000010011001010000;
        immediate_data_ext =      'b00000000000000000111000101010000;
        #20 if (alu_result     != 'b01110001010100000000000000000000) $finish;
            if (o_RegWrite     != 1) $finish;
            if (o_MemRead      != 0) $finish;
            if (o_MemWrite     != 0) $finish;
            if (o_MemtoReg     != 0) $finish;
            if (o_ls_filter_op != 'b111) $finish;
            if (o_rd           != 18) $finish;
            if (taken          != 0) $finish;
            if (pc_to_reg      != 0) $finish;
            if (o_jump_address != 0) $finish;
            if (pc_return      != 0) $finish;
        #20

        //LUI (positive case)
        opcode = {INMED, INMED_SLT};
        rt = 18;
        read_data_1 =             -5;
        immediate_data_ext =      357;
        #20 if (alu_result     != 1) $finish;
            if (o_RegWrite     != 1) $finish;
            if (o_MemRead      != 0) $finish;
            if (o_MemWrite     != 0) $finish;
            if (o_MemtoReg     != 0) $finish;
            if (o_ls_filter_op != 'b010) $finish;
            if (o_rd           != 18) $finish;
            if (taken          != 0) $finish;
            if (pc_to_reg      != 0) $finish;
            if (o_jump_address != 0) $finish;
            if (pc_return      != 0) $finish;
        #20

        //LUI (negative case)
        opcode = {INMED, INMED_SLT};
        rt = 18;
        read_data_1 =             1597;
        immediate_data_ext =      357;
        #20 if (alu_result     != 0) $finish;
            if (o_RegWrite     != 1) $finish;
            if (o_MemRead      != 0) $finish;
            if (o_MemWrite     != 0) $finish;
            if (o_MemtoReg     != 0) $finish;
            if (o_ls_filter_op != 'b010) $finish;
            if (o_rd           != 18) $finish;
            if (taken          != 0) $finish;
            if (pc_to_reg      != 0) $finish;
            if (o_jump_address != 0) $finish;
            if (pc_return      != 0) $finish;
        #20


        //branchs y jumps test
        //BEQ (positive case)
        opcode = BEQ;
        read_data_1 = 1264;
        read_data_2 = 1264;
        PCNext = 56;
        immediate_data_ext = -4;
        #20 //if (alu_result     != 0) $finish;
            if (o_RegWrite     != 0) $finish;
            if (o_MemRead      != 0) $finish;
            if (o_MemWrite     != 0) $finish;
            if (o_MemtoReg     != 0) $finish;
            //if (o_ls_filter_op != 0) $finish;
            //if (o_rd           != 18) $finish;
            if (taken          != 1) $finish;
            if (pc_to_reg      != 0) $finish;
            if (o_jump_address != 52) $finish;
            if (pc_return      != PCNext) $finish;
        #20


        //branchs y jumps test
        //BEQ (negative case)
        opcode = BEQ;
        read_data_1 = 1264;
        read_data_2 = 1597;
        PCNext = 56;
        immediate_data_ext = -4;
        #20 //if (alu_result     != 0) $finish;
            if (o_RegWrite     != 0) $finish;
            if (o_MemRead      != 0) $finish;
            if (o_MemWrite     != 0) $finish;
            if (o_MemtoReg     != 0) $finish;
            //if (o_ls_filter_op != 0) $finish;
            //if (o_rd           != 18) $finish;
            if (taken          != 0) $finish;
            if (pc_to_reg      != 0) $finish;
            if (o_jump_address != 52) $finish;
            if (pc_return      != PCNext) $finish;
        #20

        //branchs y jumps test
        //BNE (positive case)
        opcode = BNE;
        read_data_1 = 1264;
        read_data_2 = 1597;
        PCNext = 56;
        immediate_data_ext = -4;
        #20 //if (alu_result     != 0) $finish;
            if (o_RegWrite     != 0) $finish;
            if (o_MemRead      != 0) $finish;
            if (o_MemWrite     != 0) $finish;
            if (o_MemtoReg     != 0) $finish;
            //if (o_ls_filter_op != 0) $finish;
            //if (o_rd           != 18) $finish;
            if (taken          != 1) $finish;
            if (pc_to_reg      != 0) $finish;
            if (o_jump_address != 52) $finish;
            if (pc_return      != PCNext) $finish;
        #20

        //BNE (negative case)
        opcode = BNE;
        read_data_1 = 1597;
        read_data_2 = 1597;
        PCNext = 56;
        immediate_data_ext = -4;
        #20 //if (alu_result     != 0) $finish;
            if (o_RegWrite     != 0) $finish;
            if (o_MemRead      != 0) $finish;
            if (o_MemWrite     != 0) $finish;
            if (o_MemtoReg     != 0) $finish;
            //if (o_ls_filter_op != 0) $finish;
            //if (o_rd           != 18) $finish;
            if (taken          != 0) $finish;
            if (pc_to_reg      != 0) $finish;
            if (o_jump_address != 52) $finish;
            if (pc_return      != PCNext) $finish;
        #20

        //J
        opcode = J;
        read_data_1 = 1597;
        read_data_2 = 1597;
        PCNext = 645;
        jump_address = 1159;
        immediate_data_ext = -4;
        #20 //if (alu_result     != 0) $finish;
            if (o_RegWrite     != 0) $finish;
            if (o_MemRead      != 0) $finish;
            if (o_MemWrite     != 0) $finish;
            if (o_MemtoReg     != 0) $finish;
            //if (o_ls_filter_op != 0) $finish;
            //if (o_rd           != 18) $finish;
            if (taken          != 1) $finish;
            if (pc_to_reg      != 0) $finish;
            if (o_jump_address != 1159) $finish;
            if (pc_return      != PCNext) $finish;
        #20

        //JAL
        opcode = JAL;
        read_data_1 = 1597;
        read_data_2 = 1597;
        PCNext = 645;
        jump_address = 1159;
        immediate_data_ext = -4;
        #20 //if (alu_result     != 0) $finish;
            if (o_RegWrite     != 0) $finish;
            if (o_MemRead      != 0) $finish;
            if (o_MemWrite     != 0) $finish;
            if (o_MemtoReg     != 0) $finish;
            //if (o_ls_filter_op != 0) $finish;
            if (o_rd           != 31) $finish;
            if (taken          != 1) $finish;
            if (pc_to_reg      != 1) $finish;
            if (o_jump_address != 1159) $finish;
            if (pc_return      != PCNext) $finish;
        #20

        //JR
        opcode = JR_JALR;
        read_data_1 = 1597;
        read_data_2 = 1753;
        PCNext = 645;
        jump_address = 1159;
        immediate_data_ext = {{26{1'b0}}, 6'b001000};
        #20 //if (alu_result     != 0) $finish;
            if (o_RegWrite     != 0) $finish;
            if (o_MemRead      != 0) $finish;
            if (o_MemWrite     != 0) $finish;
            if (o_MemtoReg     != 0) $finish;
            //if (o_ls_filter_op != 0) $finish;
            //if (o_rd           != 31) $finish;
            if (taken          != 1) $finish;
            if (pc_to_reg      != 0) $finish;
            if (o_jump_address != 1597) $finish;
            if (pc_return      != PCNext) $finish;
        #20


        //JALR
        opcode = JR_JALR;
        read_data_1 = 1597;
        read_data_2 = 1753;
        PCNext = 645;
        jump_address = 1159;
        rd = 14;
        immediate_data_ext = {{26{1'b0}}, 6'b001001};
        #20 //if (alu_result     != 0) $finish;
            if (o_RegWrite     != 0) $finish;
            if (o_MemRead      != 0) $finish;
            if (o_MemWrite     != 0) $finish;
            if (o_MemtoReg     != 0) $finish;
            //if (o_ls_filter_op != 0) $finish;
            if (o_rd           != 14) $finish;
            if (taken          != 1) $finish;
            if (pc_to_reg      != 1) $finish;
            if (o_jump_address != 1597) $finish;
            if (pc_return      != PCNext) $finish;
        #20


        //testing fowarding (only with ADDS)
        PCNext = 0;

        //fowarding A from MEM stage
        opcode = 0;
        immediate_data_ext = { {26{1'b0}} , FUNCT_ADD};

        read_data_1 = 5;
        read_data_2 = 10;
        rs = 5;
        rt = 7;
        rd = 9;

        ex_mem_RegWrite = 1;
        mem_wb_RegWrite = 0;
        ex_mem_rd = 5;
        mem_wb_rd = 12;
        ex_mem_data = 12;
        mem_wb_data = 1;

        #20 if (alu_result     != 22) $finish;
            if (o_RegWrite     != 1) $finish;
            if (o_MemRead      != 0) $finish;
            if (o_MemWrite     != 0) $finish;
            if (o_MemtoReg     != 0) $finish;
            if (o_ls_filter_op != 0) $finish;
            if (o_rd           != 9) $finish;
            if (taken          != 0) $finish;
            if (pc_to_reg      != 0) $finish;
            if (o_jump_address != 0) $finish;
            if (pc_return      != 0) $finish;
        #20

        //fowarding B from MEM stage
        opcode = 0;
        immediate_data_ext = { {26{1'b0}} , FUNCT_ADD};

        read_data_1 = 5;
        read_data_2 = 10;
        rs = 5;
        rt = 7;
        rd = 9;

        ex_mem_RegWrite = 1;
        mem_wb_RegWrite = 0;
        ex_mem_rd = 7;
        mem_wb_rd = 12;
        ex_mem_data = 12;
        mem_wb_data = 1;

        #20 if (alu_result     != 17) $finish;
            if (o_RegWrite     != 1) $finish;
            if (o_MemRead      != 0) $finish;
            if (o_MemWrite     != 0) $finish;
            if (o_MemtoReg     != 0) $finish;
            if (o_ls_filter_op != 0) $finish;
            if (o_rd           != 9) $finish;
            if (taken          != 0) $finish;
            if (pc_to_reg      != 0) $finish;
            if (o_jump_address != 0) $finish;
            if (pc_return      != 0) $finish;
        #20

        //fowarding A from WB stage
        opcode = 0;
        immediate_data_ext = { {26{1'b0}} , FUNCT_ADD};

        read_data_1 = 5;
        read_data_2 = 10;
        rs = 5;
        rt = 7;
        rd = 9;

        ex_mem_RegWrite = 0;
        mem_wb_RegWrite = 1;
        ex_mem_rd = 12;
        mem_wb_rd = 5;
        ex_mem_data = 12;
        mem_wb_data = 1;

        #20 if (alu_result     != 11) $finish;
            if (o_RegWrite     != 1) $finish;
            if (o_MemRead      != 0) $finish;
            if (o_MemWrite     != 0) $finish;
            if (o_MemtoReg     != 0) $finish;
            if (o_ls_filter_op != 0) $finish;
            if (o_rd           != 9) $finish;
            if (taken          != 0) $finish;
            if (pc_to_reg      != 0) $finish;
            if (o_jump_address != 0) $finish;
            if (pc_return      != 0) $finish;
        #20

        //fowarding B from WB stage
        opcode = 0;
        immediate_data_ext = { {26{1'b0}} , FUNCT_ADD};

        read_data_1 = 5;
        read_data_2 = 10;
        rs = 5;
        rt = 7;
        rd = 9;

        ex_mem_RegWrite = 0;
        mem_wb_RegWrite = 1;
        ex_mem_rd = 12;
        mem_wb_rd = 7;
        ex_mem_data = 12;
        mem_wb_data = 1;

        #20 if (alu_result     != 6) $finish;
            if (o_RegWrite     != 1) $finish;
            if (o_MemRead      != 0) $finish;
            if (o_MemWrite     != 0) $finish;
            if (o_MemtoReg     != 0) $finish;
            if (o_ls_filter_op != 0) $finish;
            if (o_rd           != 9) $finish;
            if (taken          != 0) $finish;
            if (pc_to_reg      != 0) $finish;
            if (o_jump_address != 0) $finish;
            if (pc_return      != 0) $finish;
        #20


        //fowarding A from MEM stage and B from WB
        opcode = 0;
        immediate_data_ext = { {26{1'b0}} , FUNCT_ADD};

        read_data_1 = 5;
        read_data_2 = 10;
        rs = 5;
        rt = 7;
        rd = 9;

        ex_mem_RegWrite = 1;
        mem_wb_RegWrite = 1;
        ex_mem_rd = 5;
        mem_wb_rd = 7;
        ex_mem_data = 12;
        mem_wb_data = 1;

        #20 if (alu_result     != 13) $finish;
            if (o_RegWrite     != 1) $finish;
            if (o_MemRead      != 0) $finish;
            if (o_MemWrite     != 0) $finish;
            if (o_MemtoReg     != 0) $finish;
            if (o_ls_filter_op != 0) $finish;
            if (o_rd           != 9) $finish;
            if (taken          != 0) $finish;
            if (pc_to_reg      != 0) $finish;
            if (o_jump_address != 0) $finish;
            if (pc_return      != 0) $finish;
        #20


        //fowarding B from MEM stage and A from WB
        opcode = 0;
        immediate_data_ext = { {26{1'b0}} , FUNCT_ADD};

        read_data_1 = 5;
        read_data_2 = 10;
        rs = 5;
        rt = 7;
        rd = 9;

        ex_mem_RegWrite = 1;
        mem_wb_RegWrite = 1;
        ex_mem_rd = 7;
        mem_wb_rd = 5;
        ex_mem_data = 2;
        mem_wb_data = 3;

        #20 if (alu_result     != 5) $finish;
            if (o_RegWrite     != 1) $finish;
            if (o_MemRead      != 0) $finish;
            if (o_MemWrite     != 0) $finish;
            if (o_MemtoReg     != 0) $finish;
            if (o_ls_filter_op != 0) $finish;
            if (o_rd           != 9) $finish;
            if (taken          != 0) $finish;
            if (pc_to_reg      != 0) $finish;
            if (o_jump_address != 0) $finish;
            if (pc_return      != 0) $finish;
        #20

        //fowarding A from MEM stage when WB stage also wants to foward A
        opcode = 0;
        immediate_data_ext = { {26{1'b0}} , FUNCT_ADD};

        read_data_1 = 5;
        read_data_2 = 10;
        rs = 5;
        rt = 7;
        rd = 9;

        ex_mem_RegWrite = 1;
        mem_wb_RegWrite = 1;
        ex_mem_rd = 5;
        mem_wb_rd = 5;
        ex_mem_data = 12;
        mem_wb_data = 1;

        #20 if (alu_result     != 22) $finish;
            if (o_RegWrite     != 1) $finish;
            if (o_MemRead      != 0) $finish;
            if (o_MemWrite     != 0) $finish;
            if (o_MemtoReg     != 0) $finish;
            if (o_ls_filter_op != 0) $finish;
            if (o_rd           != 9) $finish;
            if (taken          != 0) $finish;
            if (pc_to_reg      != 0) $finish;
            if (o_jump_address != 0) $finish;
            if (pc_return      != 0) $finish;
        #20

        //fowarding B from MEM stage when WB stage also wants to foward B
        opcode = 0;
        immediate_data_ext = { {26{1'b0}} , FUNCT_ADD};

        read_data_1 = 5;
        read_data_2 = 10;
        rs = 5;
        rt = 7;
        rd = 9;

        ex_mem_RegWrite = 1;
        mem_wb_RegWrite = 1;
        ex_mem_rd = 7;
        mem_wb_rd = 7;
        ex_mem_data = 12;
        mem_wb_data = 1;

        #20 if (alu_result     != 17) $finish;
            if (o_RegWrite     != 1) $finish;
            if (o_MemRead      != 0) $finish;
            if (o_MemWrite     != 0) $finish;
            if (o_MemtoReg     != 0) $finish;
            if (o_ls_filter_op != 0) $finish;
            if (o_rd           != 9) $finish;
            if (taken          != 0) $finish;
            if (pc_to_reg      != 0) $finish;
            if (o_jump_address != 0) $finish;
            if (pc_return      != 0) $finish;
        #20
    ;
    end



    Execution exec_u (
        .i_PCNext(PCNext),
        .i_opcode(opcode),
        .i_read_data_1(read_data_1),
        .i_read_data_2(read_data_2),
        .i_immediate_data_ext(immediate_data_ext),
        .i_jump_address(jump_address),
        .i_rs(rs),
        .i_rt(rt),
        .i_rd(rd),
        .i_branch_enable(branch_enable),
        .i_RegDst(i_RegDst),
        .i_RegWrite(i_RegWrite),
        .i_MemRead(i_MemRead),
        .i_MemWrite(i_MemWrite),
        .i_MemtoReg(i_MemtoReg),
        .i_ALUOp(i_ALUOp),
        .i_ALUSrc(i_ALUSrc),
        .i_Shamt(i_Shamt),
        .i_ls_filter_op(i_ls_filter_op),
        .i_ex_mem_data(ex_mem_data),
        .i_mem_wb_data(mem_wb_data),
        .i_ex_mem_RegWrite(ex_mem_RegWrite),
        .i_mem_wb_RegWrite(mem_wb_RegWrite),
        .i_ex_mem_rd(ex_mem_rd),
        .i_mem_wb_rd(mem_wb_rd),
        
        .o_alu_result(alu_result),
        .o_rt_data(rt_data),
        .o_rd(o_rd),
        .o_taken(taken),
        .o_pc_to_reg(pc_to_reg),
        .o_jump_address(o_jump_address),
        .o_pc_return(pc_return),
        .o_RegWrite(o_RegWrite),
        .o_MemRead(o_MemRead),
        .o_MemWrite(o_MemWrite),
        .o_MemtoReg(o_MemtoReg),
        .o_ls_filter_op(o_ls_filter_op)

    );

    Control Control_u(
        .i_opcode(opcode),
        .i_funct(funct),
        .i_control_mux(control_mux),
        .o_RegDst(i_RegDst),
        .o_RegWrite(i_RegWrite),
        .o_MemRead(i_MemRead),
        .o_MemWrite(i_MemWrite),
        .o_MemtoReg(i_MemtoReg),
        .o_ALUOp(i_ALUOp),
        .o_ALUSrc(i_ALUSrc),
        .o_Shamt(i_Shamt),
        .o_ls_filter_op(i_ls_filter_op)
    );

endmodule
