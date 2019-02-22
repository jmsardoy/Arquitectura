`timescale 1ns/1ps

module ALUControl
(
    input wire [3 : 0] i_ALUOp,
    input wire [5 : 0] i_funct,

    output reg [3 : 0] o_operation
);

    localparam ALU_ADD  = 'b0000;
    localparam ALU_SUB  = 'b0001;
    localparam ALU_AND  = 'b0010;
    localparam ALU_OR   = 'b0011;
    localparam ALU_XOR  = 'b0100;
    localparam ALU_NOR  = 'b0101;
    localparam ALU_SLT  = 'b0110;
    localparam ALU_SLL  = 'b0111;
    localparam ALU_SRL  = 'b1000;
    localparam ALU_SRA  = 'b1001;
    localparam ALU_LUI  = 'b1010;

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

    localparam INMED_ADD  = 'b000;
    localparam INMED_AND  = 'b100;
    localparam INMED_OR   = 'b101;
    localparam INMED_XOR  = 'b110;
    localparam INMED_LUI  = 'b111;
    localparam INMED_SLT  = 'b010;

    always@* begin

        if (i_ALUOp == 'b0000) begin
            case (i_funct)
                FUNCT_ADD:  o_operation = ALU_ADD;
                FUNCT_ADDU: o_operation = ALU_ADD;
                FUNCT_SUB:  o_operation = ALU_SUB;
                FUNCT_SUBU: o_operation = ALU_SUB;
                FUNCT_AND:  o_operation = ALU_AND;
                FUNCT_OR:   o_operation = ALU_OR;
                FUNCT_XOR:  o_operation = ALU_XOR;
                FUNCT_NOR:  o_operation = ALU_NOR;
                FUNCT_SLT:  o_operation = ALU_SLT;
                FUNCT_SLL:  o_operation = ALU_SLL;
                FUNCT_SRL:  o_operation = ALU_SRL;
                FUNCT_SRA:  o_operation = ALU_SRA;
                FUNCT_SLLV: o_operation = ALU_SLL;
                FUNCT_SRLV: o_operation = ALU_SRL;
                FUNCT_SRAV: o_operation = ALU_SRA;
                default:    o_operation = 0;
            endcase
        end

        else if (i_ALUOp == 'b0001) begin
            o_operation = ALU_ADD;
        end

        else if (i_ALUOp[3] == 1) begin
            case (i_ALUOp[2:0])
                INMED_ADD: o_operation = ALU_ADD;
                INMED_AND: o_operation = ALU_AND;
                INMED_OR:  o_operation = ALU_OR;
                INMED_XOR: o_operation = ALU_XOR;
                INMED_LUI: o_operation = ALU_LUI;
                INMED_SLT: o_operation = ALU_SLT;
                default:   o_operation = 0;
            endcase
        end
        
        else o_operation = 0;
   
   end


endmodule
