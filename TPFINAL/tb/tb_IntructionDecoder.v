
module tb_InstructionDecoder();

    reg clk;
    reg rst;
    reg [31:0] write_data;
    reg [4:0] mem_wb_rd;
    reg mem_wb_RegWrite;

    reg [4:0] id_ex_rt;
    reg id_ex_MemRead;
    wire PCWrite;
    wire if_id_write;

    wire       RegDst;
    wire [1:0] ALUOp;
    wire       ALUSrc;
    wire       Branch;
    wire       MemRead;
    wire       MemWrite;
    wire       RegWrite;
    wire       MemtoReg;

    wire [31 : 0] read_data_1;
    wire [31 : 0] read_data_2;
    wire [31 : 0] immediate_data_ext;

    wire [4:0] rs;
    wire [4:0] rt;
    wire [4:0] rd;

    wire [32*32 - 1 : 0] rf_regs;


    reg [5:0] opcode_aux;
    reg [4:0] rs_aux;
    reg [4:0] rt_aux;
    reg [15:0] immediate_aux; 
    wire [31:0] instruction = {opcode_aux, rs_aux, rt_aux, immediate_aux};

    integer i;

    localparam RFORMAT = 'b000000;
    localparam LW      = 'b100011;
    localparam SW      = 'b101011;
    localparam BEQ     = 'b000100;

    initial begin
        clk = 1;

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

    end

    always #10 clk = ~clk;

    InstructionDecoder ID_u(
        .clk(clk),
        .rst(rst),
        .i_instruction(instruction),
        .i_write_data(write_data),
        .i_mem_wb_rd(mem_wb_rd),
        .i_mem_wb_RegWrite(mem_wb_RegWrite),
        .i_id_ex_rt(id_ex_rt),
        .i_id_ex_MemRead(id_ex_MemRead),
        .o_PCWrite(PCWrite),
        .o_if_id_write(if_id_write),
        .o_RegDst(RegDst),
        .o_ALUOp(ALUOp),
        .o_ALUSrc(ALUSrc),
        .o_Branch(Branch),
        .o_MemRead(MemRead),
        .o_MemWrite(MemWrite),
        .o_MemtoReg(MemtoReg),
        .o_read_data_1(read_data_1),
        .o_read_data_2(read_data_2),
        .o_immediate_data_ext(immediate_data_ext),
        .o_rs(rs),
        .o_rt(rt),
        .o_rd(rd),
        .o_rf_regs(rf_regs)
    );







endmodule
