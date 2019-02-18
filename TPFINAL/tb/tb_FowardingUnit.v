`timescale 1ns / 1ps


module tb_FowardingUnit();

    reg ex_mem_RegWrite;
    reg mem_wb_RegWrite;
    reg [5:0] id_ex_rs;
    reg [5:0] id_ex_rt;
    reg [5:0] ex_mem_rd;
    reg [5:0] mem_wb_rd;

    wire [1:0] foward_A;
    wire [1:0] foward_B;

    initial begin
        
        //RegWrites == 0
        ex_mem_RegWrite = 0;
        mem_wb_RegWrite = 0;
        id_ex_rs = 0;
        id_ex_rt = 0;
        ex_mem_rd = 0;
        mem_wb_rd = 0;

        #20

        //testing if reg O condition holds
        ex_mem_RegWrite = 1;
        mem_wb_RegWrite = 1;
        id_ex_rs = 0;
        id_ex_rt = 0;
        ex_mem_rd = 0;
        mem_wb_rd = 0;

        #20

        //foward A from MEM stage
        ex_mem_RegWrite = 1;
        mem_wb_RegWrite = 0;
        id_ex_rs = 10;
        id_ex_rt = 5;
        ex_mem_rd = 10;
        mem_wb_rd = 12;
        
        #20

        //foward B from MEM stage
        ex_mem_RegWrite = 1;
        mem_wb_RegWrite = 0;
        id_ex_rs = 10;
        id_ex_rt = 5;
        ex_mem_rd = 5;
        mem_wb_rd = 12;

        #20

        //foward A from WB stage
        ex_mem_RegWrite = 0;
        mem_wb_RegWrite = 1;
        id_ex_rs = 10;
        id_ex_rt = 5;
        ex_mem_rd = 12;
        mem_wb_rd = 10;

        #20

        //foward B from WB stage
        ex_mem_RegWrite = 0;
        mem_wb_RegWrite = 1;
        id_ex_rs = 10;
        id_ex_rt = 5;
        ex_mem_rd = 12;
        mem_wb_rd = 5;

        #20

        //foward A from MEM when condition from WB also is true
        ex_mem_RegWrite = 1;
        mem_wb_RegWrite = 1;
        id_ex_rs = 10;
        id_ex_rt = 5;
        ex_mem_rd = 10;
        mem_wb_rd = 10;

        #20

        //foward B from MEM when condition from WB also is true
        ex_mem_RegWrite = 1;
        mem_wb_RegWrite = 1;
        id_ex_rs = 10;
        id_ex_rt = 5;
        ex_mem_rd = 5;
        mem_wb_rd = 5;

        #20

        //foward A from MEM and B from WB
        ex_mem_RegWrite = 1;
        mem_wb_RegWrite = 1;
        id_ex_rs = 10;
        id_ex_rt = 5;
        ex_mem_rd = 10;
        mem_wb_rd = 5;
    
        #20

        //foward B from MEM and A from WB
        ex_mem_RegWrite = 1;
        mem_wb_RegWrite = 1;
        id_ex_rs = 10;
        id_ex_rt = 5;
        ex_mem_rd = 5;
        mem_wb_rd = 10;

        #20

        //foward B from MEM and A from WB
        ex_mem_RegWrite = 1;
        mem_wb_RegWrite = 1;
        id_ex_rs = 10;
        id_ex_rt = 10;
        ex_mem_rd = 10;
        mem_wb_rd = 10;
    end



    FowardingUnit foward_unit_u(
        .i_ex_mem_RegWrite(ex_mem_RegWrite),
        .i_mem_wb_RegWrite(mem_wb_RegWrite),
        .i_id_ex_rs(id_ex_rs),
        .i_id_ex_rt(id_ex_rt),
        .i_ex_mem_rd(ex_mem_rd),
        .i_mem_wb_rd(mem_wb_rd),
        .o_foward_A(foward_A),
        .o_foward_B(foward_B)
    );

endmodule
