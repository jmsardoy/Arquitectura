`timescale 1ns/1ps

module tb_ALUControl();


    reg [3:0] ALUOp;
    reg [5:0] funct;

    wire [3:0] operation;

    localparam FUNCT_ADD  = 'b100000;
    localparam FUNCT_ADDU = 'b100001;
    localparam FUNCT_SUB  = 'b100010;
    localparam FUNCT_SUBU = 'b100011;
    localparam FUNCT_AND  = 'b100100;
    localparam FUNCT_OR   = 'b100101;
    localparam FUNCT_XOR  = 'b100110;
    localparam FUNCT_NOR  = 'b100111;
    localparam FUNCT_SLT  = 'b101010;
    localparam FUNCT_SLL  = 'b000000;
    localparam FUNCT_SRL  = 'b000010;
    localparam FUNCT_SRA  = 'b000011;
    localparam FUNCT_SLLV = 'b000100;
    localparam FUNCT_SRLV = 'b000110;
    localparam FUNCT_SRAV = 'b000111;

    localparam INMED_ADD  = 3'b000;
    localparam INMED_AND  = 3'b100;
    localparam INMED_OR   = 3'b101;
    localparam INMED_XOR  = 3'b110;
    localparam INMED_LUI  = 3'b111;
    localparam INMED_SLT  = 3'b010;


    initial begin
        //R-TYPE

        //ADD
        ALUOp = 'b0000;
        funct = FUNCT_ADD;
        #20

        //ADDU
        ALUOp = 'b0000;
        funct = FUNCT_ADDU;
        #20

        //SUB
        ALUOp = 'b0000;
        funct = FUNCT_SUB;
        #20

        //SUBU
        ALUOp = 'b0000;
        funct = FUNCT_SUBU;
        #20

        //AND
        ALUOp = 'b0000;
        funct = FUNCT_AND;
        #20

        //OR
        ALUOp = 'b0000;
        funct = FUNCT_OR;
        #20

        //XOR
        ALUOp = 'b0000;
        funct = FUNCT_XOR;
        #20

        //NOR
        ALUOp = 'b0000;
        funct = FUNCT_NOR;
        #20

        //SLT
        ALUOp = 'b0000;
        funct = FUNCT_SLT;
        #20

        //SLL
        ALUOp = 'b0000;
        funct = FUNCT_SLL;
        #20

        //SRL
        ALUOp = 'b0000;
        funct = FUNCT_SRL;
        #20

        //SRA
        ALUOp = 'b0000;
        funct = FUNCT_SRA;
        #20

        //SLLV
        ALUOp = 'b0000;
        funct = FUNCT_SLLV;
        #20

        //SRLV
        ALUOp = 'b0000;
        funct = FUNCT_SRLV;
        #20

        //SRAV 
        ALUOp = 'b0000;
        funct = FUNCT_SRAV;
        #20

        //BREAK
        ALUOp = 'b0100;
        funct = 0;
        #60

        // LOAD/STORE
        ALUOp = 'b0001;
        #20

        //BREAK
        ALUOp = 'b0100;
        funct = 0;
        #60

        //INMEDIATES

        //ADDI
        ALUOp = {1, INMED_ADD};
        #20

        //ANDI
        ALUOp = {1, INMED_AND};
        #20

        //ORI
        ALUOp = {1, INMED_OR};
        #20

        //XORI
        ALUOp = {1, INMED_XOR};
        #20

        //LUI
        ALUOp = {1, INMED_LUI};
        #20

        //SLTI
        ALUOp = {1, INMED_SLT};
        #20

        //BREAK
        ALUOp = 'b0100;
        funct = 0;




    end

    ALUControl alu_control_u (
        .i_ALUOp(ALUOp),
        .i_funct(funct),
        .o_operation(operation)
    );

endmodule
