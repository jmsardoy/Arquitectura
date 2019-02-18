`include "constants.vh"

module tb_InstructionDecoder();

    localparam PC_BITS = `PC_BITS;
    localparam PROC_BITS = `PROC_BITS;
    localparam REG_ADDRS_BITS = `REG_ADDRS_BITS;
    localparam OPCODE_BITS = `OPCODE_BITS;
    localparam INSTRUCTION_BITS = `INSTRUCTION_BITS;

    reg clk;
    reg rst;
    reg [PROC_BITS - 1 : 0 ]      i_PCNext;
    reg [PROC_BITS - 1 : 0 ]      write_data;
    reg [REG_ADDRS_BITS - 1 : 0 ] mem_wb_rd;
    reg mem_wb_RegWrite;

    reg [REG_ADDRS_BITS - 1 : 0 ] id_ex_rt;
    reg id_ex_MemRead;
    wire [PROC_BITS - 1 : 0 ] o_PCNext;
    wire [OPCODE_BITS - 1 : 0 ] opcode;
    wire PCWrite;
    wire if_id_write;

    wire       RegDst;
    wire       RegWrite;
    wire       MemRead;
    wire       MemWrite;
    wire       MemtoReg;
    wire [3:0] ALUOp;
    wire       ALUSrc;
    wire       ls_filter_op;

    wire [PROC_BITS - 1 : 0] read_data_1;
    wire [PROC_BITS - 1 : 0] read_data_2;
    wire [PROC_BITS - 1 : 0] immediate_data_ext;
    wire [PROC_BITS - 1 : 0] jump_address;

    wire [REG_ADDRS_BITS - 1 : 0] rs;
    wire [REG_ADDRS_BITS - 1 : 0] rt;
    wire [REG_ADDRS_BITS - 1 : 0] rd;

    wire [32*32 - 1 : 0] rf_regs;


    reg [OPCODE_BITS - 1 : 0] opcode_aux;
    reg [REG_ADDRS_BITS - 1 : 0] rs_aux;
    reg [REG_ADDRS_BITS - 1 : 0] rt_aux;
    reg [15:0] immediate_aux; 
    wire [INSTRUCTION_BITS - 1 : 0] instruction = {opcode_aux, rs_aux, rt_aux, immediate_aux};

    integer i;

    localparam RFORMAT = 'b000000;
    localparam LW      = 'b100011;
    localparam SW      = 'b101011;
    localparam BEQ     = 'b000100;

    initial begin
        clk = 1;
        i_PCNext = 8;

        //testing write in registerFile
        mem_wb_RegWrite = 1;
        for(i=0; i<32; i=i+1) begin
            mem_wb_rd = i;
            write_data = i*10;
            #20;
        end
        mem_wb_RegWrite = 0;

        //testing reads
        #20
        for(i=0; i<32; i=i+1) begin
            opcode_aux = RFORMAT;
            rs_aux = i;
            rt_aux = i;
            immediate_aux = 0;
            #20;
        end

        //testing reads out of phase
        #20
        for(i=0; i<32; i=i+1) begin
            opcode_aux = RFORMAT;
            rs_aux = i;
            rt_aux = i+2;
            immediate_aux = 0;
            #20;
        end

        //testing sign ext
        immediate_aux = 28089;
        #20
        immediate_aux = -62;
        #20

        //testing jump_adddress
        opcode_aux = 'b000010;
        {rs_aux, rt_aux, immediate_aux} = 'b0000000000000000000001011;
        

    end

    always #10 clk = ~clk;

    InstructionDecoder ID_u(
        .clk(clk),
        .rst(rst),
        .i_instruction(instruction),
        .i_PCNext(i_PCNext),
        .i_write_data(write_data),
        .i_mem_wb_rd(mem_wb_rd),
        .i_mem_wb_RegWrite(mem_wb_RegWrite),
        .i_id_ex_rt(id_ex_rt),
        .i_id_ex_MemRead(id_ex_MemRead),
        .o_PCNext(o_PCNext),
        .o_opcode(opcode),
        .o_PCWrite(PCWrite),
        .o_if_id_write(if_id_write),
        .o_RegDst(RegDst),
        .o_RegWrite(RegWrite),
        .o_MemRead(MemRead),
        .o_MemWrite(MemWrite),
        .o_MemtoReg(MemtoReg),
        .o_ALUOp(ALUOp),
        .o_ALUSrc(ALUSrc),
        .o_ls_filter_op(ls_filter_op),
        .o_read_data_1(read_data_1),
        .o_read_data_2(read_data_2),
        .o_immediate_data_ext(immediate_data_ext),
        .o_jump_address(jump_address),
        .o_rs(rs),
        .o_rt(rt),
        .o_rd(rd),
        .o_rf_regs(rf_regs)
    );







endmodule
