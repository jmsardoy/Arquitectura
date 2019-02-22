`timescale 1ns / 1ps

`include "constants.vh"

module LoadInstFSM
#(
    parameter UART_BITS = `UART_BITS,

    parameter INST_ADDRS_BITS   = `INST_ADDRS_BITS,
    parameter INSTRUCTION_BITS = `INSTRUCTION_BITS
)
(
    input wire clk,
    input wire rst,
    input wire i_start,
    input wire i_rx_done,
    input wire [UART_BITS - 1 : 0] i_rx_data,
    
    output reg                            o_write_inst_mem,
    output reg [INST_ADDRS_BITS - 1 : 0]  o_inst_mem_addr,
    output reg [INSTRUCTION_BITS - 1 : 0] o_inst_mem_data,
    output reg                            o_done
);


    localparam IDLE           = 0;
    localparam GET_INST_COUNT = 1;
    localparam GET_DATA       = 2;
    localparam WRITE_DATA     = 3;
    localparam FINISH         = 4;

    reg [2:0] state;
    reg [2:0] next_state;


    //fsm inner logic regs
    reg [2:0]                      bytes_count;
    reg [INST_ADDRS_BITS - 1 : 0]  inst_count;
    reg [INST_ADDRS_BITS - 1 : 0]  inst_addr;
    reg [INSTRUCTION_BITS - 1 : 0] inst_data;

    always@(posedge clk) begin
        if (!rst) begin
            state <= IDLE;
        end
        else begin
            state <= next_state;
        end
    end

    //state change logic
    always@* begin
        if (!rst) begin
            next_state = IDLE;
        end
        else begin
            case(state)
                IDLE: begin
                    if (i_start) next_state = GET_INST_COUNT;
                    else         next_state = IDLE;
                end
                //assumes that rx_data len < inst_count len
                GET_INST_COUNT: begin
                    if (inst_count != 0) next_state = GET_DATA;
                    else                 next_state = GET_INST_COUNT;
                end
                GET_DATA: begin
                    //assumes INSTRUCTION_BITS = 32 and UART_BITS = 8
                    if (bytes_count == 4) next_state = WRITE_DATA;
                    else                  next_state = GET_DATA;
                end
                WRITE_DATA: begin
                    if (inst_count == 0) next_state = FINISH;
                    else                 next_state = GET_DATA;
                end
                FINISH: begin
                    next_state = IDLE;
                end
            endcase
        end
    end

    //output logic
    always@* begin
        case(state)
            IDLE: begin
                o_write_inst_mem = 0;
                o_inst_mem_addr  = 0;
                o_inst_mem_data  = 0;
                o_done           = 0;
            end
            GET_INST_COUNT: begin
                o_write_inst_mem = 0;
                o_inst_mem_addr  = 0;
                o_inst_mem_data  = 0;
                o_done           = 0;
            end
            GET_DATA: begin
                o_write_inst_mem = 0;
                o_inst_mem_addr  = 0;
                o_inst_mem_data  = 0;
                o_done           = 0;
            end
            WRITE_DATA: begin
                o_write_inst_mem = 1;
                o_inst_mem_addr  = inst_addr;
                o_inst_mem_data  = inst_data;
                o_done           = 0;
            end
            FINISH: begin
                o_write_inst_mem = 0;
                o_inst_mem_addr  = 0;
                o_inst_mem_data  = 0;
                o_done           = 1;
            end
        endcase
    end

    //inner logic
    always@(posedge clk) begin
        if (!rst) begin
            bytes_count  <= 0;
            inst_count   <= 0;
            inst_addr    <= 0;
            inst_data    <= 0;
        end
        else begin
            case (state)
                GET_INST_COUNT: begin
                    if (i_rx_done) begin
                        bytes_count  <= 0;
                        inst_count   <= i_rx_data;
                        inst_addr    <= 0;
                        inst_data    <= 0;
                    end
                end
                GET_DATA: begin
                    if (i_rx_done) begin
                        bytes_count  <= bytes_count + 1;
                        //MSB should be send first
                        inst_data    <= {inst_data[INSTRUCTION_BITS - UART_BITS - 1 : 0],
                                         i_rx_data};
                    end
                end
                WRITE_DATA: begin
                    bytes_count <= 0;
                    inst_count  <= inst_count - 1;
                    inst_addr   <= inst_addr + 1;
                end
            endcase
        end
    end

endmodule

