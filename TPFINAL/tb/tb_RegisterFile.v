`timescale 1ns / 1ps

`include "constants.vh"

module tb_RegisterFile
#(
    // -1 to have MSB index ready
    parameter REG_ADDRS_BITS_I  = `REG_ADDRS_BITS - 1,
    parameter PROC_BITS_I       = `PROC_BITS - 1,
    parameter DEBUG_BITS_I      = (`PROC_BITS*`PROC_BITS) - 1
)();

    reg                          clk;
    reg                          reg_write;
    reg  [REG_ADDRS_BITS_I:0]    read_register_1;
    reg  [REG_ADDRS_BITS_I:0]    read_register_2;
    reg  [REG_ADDRS_BITS_I:0]    write_register;
    reg  [PROC_BITS_I     :0]    write_data;
    wire [PROC_BITS_I     :0]    read_data_1;
    wire [PROC_BITS_I     :0]    read_data_2;
    wire [DEBUG_BITS_I    :0]    debug_regs;

    initial begin
        clk = 1;
        reg_write = 0;
        read_register_1 = 0;
        read_register_2 = 0;
        write_register = 0;
        write_data = 0;

        // Write register 0 with data 17
        #20
        reg_write = 1;
        write_register = 0;
        write_data = 17;
        // Write register 1 with data 3
        #20
        reg_write = 1;
        write_register = 1;
        write_data = 3;
        // Read output 1 with content of register 1 and output 2 with content of register 0
        #20
        read_register_1 = 1;
        read_register_2 = 0;
        // Check write disable
        #20
        reg_write = 0;
        write_data = 144; // Shouldn't take effect
    end

    always #10 clk = ~clk;


    RegisterFile RF(
    .clk(clk),
    .i_reg_write(reg_write),
    .i_read_register_1(read_register_1),
    .i_read_register_2(read_register_2),
    .i_write_register(write_register),
    .i_write_data(write_data),
    .o_read_data_1(read_data_1),
    .o_read_data_2(read_data_2),
    .o_debug_regs(debug_regs)
    );

endmodule

