`timescale 1ns / 1ps

`define BUS_LEN 8

module top_level(
                 clk,
                 input_rst,
                 buttonA,
                 buttonB,
                 button_opcode,
                 switches,
                 leds
                );

    localparam BUS_LEN = `BUS_LEN;

    input [BUS_LEN-1 : 0] switches;
    input buttonA, buttonB, button_opcode, clk;
    input input_rst;
    output wire [BUS_LEN-1 : 0] leds;

    reg [BUS_LEN-1 : 0] A;
    reg [BUS_LEN-1 : 0] B;
    reg [5 : 0] opcode;

    ALU alu(.A(A),.B(B),.opcode(opcode),.out(leds));

    wire rst;
    assign rst = ~input_rst;

    always@(posedge clk or negedge rst)
    begin
        if (rst==0)
        begin
            A <= 0;
            B <= 0;
            opcode <= 0;
        end
        else
        begin
            if (buttonA)
                A <= switches;
            if (buttonB)
                B <= switches;
            if (button_opcode)
                opcode <= switches[5:0];
        end
    end
	
endmodule
