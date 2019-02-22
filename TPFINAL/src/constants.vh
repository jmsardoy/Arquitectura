`ifndef CONSTANTS_VH
`define CONSTANTS_VH

`define PROC_BITS 32        // General processor bit size
`define REG_ADDRS_BITS 5    // Registers addresses bit size
`define PC_BITS 32
`define OPCODE_BITS 6
`define INSTRUCTION_BITS 32
`define FUNCT_BITS 6
`define INST_ADDRS_BITS 8
`define DATA_ADDRS_BITS 8

`define IF_ID_LEN  64
`define ID_EX_LEN  196
`define EX_MEM_LEN 142
`define MEM_WB_LEN 104
`define RF_REGS_LEN 32*32


//R-TYPE
`define ADD_OP  'b000000
`define SUB_OP  'b000000
`define AND_OP  'b000000
`define OR_OP   'b000000
`define XOR_OP  'b000000
`define NOR_OP  'b000000
`define SLT_OP  'b000000
`define SLL_OP  'b000000
`define SRL_OP  'b000000
`define SRA_OP  'b000000
`define SLLV_OP 'b000000
`define SRLV_OP 'b000000
`define SRAV_OP 'b000000
`define ADDU_OP 'b000000
`define SUBU_OP 'b000000

`define ADD_FUNCT  'b100000
`define SUB_FUNCT  'b100010
`define AND_FUNCT  'b100100
`define OR_FUNCT   'b100101
`define XOR_FUNCT  'b100110
`define NOR_FUNCT  'b100111
`define SLT_FUNCT  'b101010
`define SLL_FUNCT  'b000000
`define SRL_FUNCT  'b000010
`define SRA_FUNCT  'b000011
`define SLLV_FUNCT 'b000100
`define SRLV_FUNCT 'b000110
`define SRAV_FUNCT 'b000111
`define ADDU_FUNCT 'b100001
`define SUBU_FUNCT 'b100011

//I-TYPE
`define LB_OP  'b100000
`define LH_OP  'b100001
`define LW_OP  'b100011
`define LBU_OP 'b100100
`define LHU_OP 'b100101

`define SB_OP 'b101000
`define SH_OP 'b101001
`define SW_OP 'b101011

`define ADDI_OP 'b001000
`define ANDI_OP 'b001100
`define ORI_OP  'b001101
`define XORI_OP 'b001110
`define LUI_OP  'b001111
`define SLTI_OP 'b001010

`define BEQ_OP 'b000100
`define BNE_OP 'b000101
`define J_OP   'b000010
`define JAL_OP 'b000011

//J-TYPE
`define JR_OP   'b000000
`define JARL_OP 'b000000

`define JR_FUNCT   'b001000
`define JARL_FUNCT 'b001001


`endif
