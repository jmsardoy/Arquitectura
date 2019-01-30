`timescale 1ns / 1ps


module tb_HazardDetector();

    reg [4:0] rs;
    reg [4:0] rt;
    wire [9:0] instruction_rs_rt = {rs, rt};
    reg [4:0] id_ex_rt;
    reg id_ex_MemRead;
    wire PCWrite;
    wire if_id_write;
    wire control_mux;

    initial begin
        //testing MemRead == 0
        id_ex_MemRead = 0;
        rs = 0;
        rt = 0;
        id_ex_rt = 0;
        
        //testing all posibilities

        //all register diferent
        #20
        id_ex_MemRead = 1;
        rs = 1;
        rt = 2;
        id_ex_rt = 3;

        //rs == id_ex_rt
        #20
        id_ex_MemRead = 1;
        rs = 10;
        rt = 2;
        id_ex_rt = 10;

        //rt == id_ex_rt
        #20
        id_ex_MemRead = 1;
        rs = 10;
        rt = 25;
        id_ex_rt = 25;

        //rs == rt == id_ex_rt
        #20
        id_ex_MemRead = 1;
        rs = 15;
        rt = 15;
        id_ex_rt = 15;

        //rs == rt == id_ex_rt and MemRead == 0
        #20
        id_ex_MemRead = 0;
        rs = 15;
        rt = 15;
        id_ex_rt = 15;
    end

    HazardDetector hazard_detector_u(
        .i_instruction_rs_rt(instruction_rs_rt),
        .i_id_ex_rt(id_ex_rt),
        .i_id_ex_MemRead(id_ex_MemRead),
        .o_PCWrite(PCWrite),
        .o_if_id_write(if_id_write),
        .o_control_mux(control_mux)
    );


endmodule
