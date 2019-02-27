`timescale 1ns / 1ps

`include "constants.vh"

module SendDataFSM
#(
    parameter UART_BITS = `UART_BITS,

    parameter PC_BITS          = `PC_BITS,
    parameter INSTRUCTION_BITS = `INSTRUCTION_BITS,
    parameter PROC_BITS        = `PROC_BITS,
    parameter REG_ADDRS_BITS   = `REG_ADDRS_BITS,
    parameter OPCODE_BITS      = `OPCODE_BITS,
    parameter DATA_ADDRS_BITS  = `DATA_ADDRS_BITS,

    
    parameter CLK_COUNTER_BITS = `CLK_COUNTER_BITS,
    parameter IF_ID_LEN  = `IF_ID_LEN,
    parameter ID_EX_LEN  = `ID_EX_LEN,
    parameter EX_MEM_LEN = `EX_MEM_LEN,
    parameter MEM_WB_LEN = `MEM_WB_LEN,
    parameter RF_REGS_LEN = `RF_REGS_LEN
)
(
    input clk,
    input rst,
    input i_start,

    //inputs from uart
    input i_tx_done,

    //inputs from datapath
    input wire [RF_REGS_LEN - 1 : 0]      i_rf_regs,
    input wire [IF_ID_LEN - 1 : 0]        i_if_id_signals,
    input wire [ID_EX_LEN - 1 : 0]        i_id_ex_signals,
    input wire [EX_MEM_LEN - 1 : 0]       i_ex_mem_signals,
    input wire [MEM_WB_LEN - 1 : 0]       i_mem_wb_signals,
    input wire [PROC_BITS - 1 : 0]        i_mem_data,
    input wire [CLK_COUNTER_BITS - 1 : 0] i_clk_count,

    //output to datapath
    output reg                            o_debug_read_data,
    output reg [DATA_ADDRS_BITS - 1 : 0]  o_debug_read_address,

    //outputs to uart
    output reg o_tx_start,
    output reg [UART_BITS - 1 : 0] o_tx_data,
    output wire [3:0] o_state,

    output reg o_done
);

    //offset is for making regs_len a multiple of 8 (UART_LEN)
    localparam OFFSET = 6;

    localparam ALL_REGS_LEN = CLK_COUNTER_BITS + RF_REGS_LEN + IF_ID_LEN + 
                              ID_EX_LEN + EX_MEM_LEN + MEM_WB_LEN + OFFSET;

    //amount of 8-bits regs to be sended
    localparam REGS_COUNT = ALL_REGS_LEN/UART_BITS;
    
    //number of bits of sended regs counter
    localparam REG_COUNTER_LEN = $clog2(REGS_COUNT);


    wire [ALL_REGS_LEN - 1 : 0] all_regs_data;

    assign all_regs_data = {i_clk_count, i_rf_regs, i_if_id_signals, 
                            i_id_ex_signals, i_ex_mem_signals, 
                            i_mem_wb_signals,
                           {OFFSET{1'b1}}}; //fill with offset number of 0's

    reg [ALL_REGS_LEN - 1 : 0] all_regs_latch;



    localparam IDLE             = 0;
    localparam LATCH_REG        = 1;
    localparam WAIT_TX_1        = 2;
    localparam SEND_REG         = 3;
    localparam WAIT_TX_2        = 4;
    localparam SET_MEM_ADDRESS  = 5;
    localparam LATCH_MEM_DATA   = 6;
    localparam HOLD_MEM_ADDRESS = 7;
    localparam LATCH_MEM_BYTE   = 8;
    localparam WAIT_TX_3        = 9;
    localparam SEND_MEM_BYTE    = 10;
    localparam WAIT_TX_4        = 11;
    localparam FINISH           = 12;


    reg [3:0] state;
    reg [3:0] next_state;
    assign o_state = state;

    //reg to keep count of how many regs are already sended
    reg [REG_COUNTER_LEN - 1 : 0] sended_regs_count;

    //8-bits reg to latch data before sending it
    reg [UART_BITS - 1 : 0] send_data;

    //reg to hold memory address
    reg [DATA_ADDRS_BITS - 1 : 0] mem_address;

    //reg to keep count of bytes sended of one line of memory
    reg [2:0] bytes_count;

    //reg to latch mem data while sending it
    reg [PROC_BITS - 1 : 0] mem_data;

    //reg to count tx_done up to 2 to ensure that is not sending
    reg [1:0] tx_wait_count;
    
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
                    if (i_start) next_state = LATCH_REG;
                    else         next_state = IDLE;
                end
                LATCH_REG: begin
                    next_state = WAIT_TX_1;
                end
                WAIT_TX_1: begin
                    if (tx_wait_count == 2) next_state = SEND_REG;
                    else                    next_state = WAIT_TX_1;
                end
                SEND_REG: begin
                    if (sended_regs_count == 0) next_state = WAIT_TX_2;
                    else                        next_state = LATCH_REG;
                end
                WAIT_TX_2: begin
                    if (tx_wait_count == 2) next_state =  SET_MEM_ADDRESS;
                    else                    next_state = WAIT_TX_2;
                end
                SET_MEM_ADDRESS: begin
                    next_state = LATCH_MEM_DATA;
                end
                LATCH_MEM_DATA: begin
                    next_state = HOLD_MEM_ADDRESS;
                end
                HOLD_MEM_ADDRESS: begin
                    next_state = LATCH_MEM_BYTE;
                end
                LATCH_MEM_BYTE: begin
                    next_state = WAIT_TX_3;
                end
                WAIT_TX_3: begin
                    if (tx_wait_count == 2) next_state = SEND_MEM_BYTE;
                    else                    next_state = WAIT_TX_3;
                end
                SEND_MEM_BYTE: begin
                    if (bytes_count == 4) begin
                        //at this point, mem_address == 0 means that the 
                        //whole memory has been read
                        if (mem_address == 0) begin
                            next_state = WAIT_TX_4;
                        end
                        //a whole memory line has been sended but not the whole
                        //memory
                        else begin
                            next_state = SET_MEM_ADDRESS;
                        end
                    end
                    //a memory line is not sended completely
                    else begin
                        next_state = LATCH_MEM_BYTE;
                    end
                end
                WAIT_TX_4: begin
                    if (tx_wait_count == 2) next_state = FINISH;
                    else                    next_state = WAIT_TX_4;
                end
                FINISH: begin
                    next_state = IDLE;
                end
                default: next_state = IDLE;

            endcase
        end
    end

    //output logic
    always@* begin
        case (state)
            IDLE: begin
                o_debug_read_data = 0;
                o_debug_read_address = 0;
                o_tx_start = 0;
                o_tx_data = 0;
                o_done = 0;
            end
            SEND_REG: begin
                o_debug_read_data = 1;
                o_debug_read_address = 0;
                o_tx_start = 1;
                o_tx_data = send_data;
                o_done = 0;
            end
            SET_MEM_ADDRESS: begin
                o_debug_read_data = 1;
                o_debug_read_address = mem_address;
                o_tx_start = 0;
                o_tx_data = 0;
                o_done = 0;
            end
            LATCH_MEM_DATA: begin
                o_debug_read_data = 1;
                o_debug_read_address = mem_address;
                o_tx_start = 0;
                o_tx_data = 0;
                o_done = 0;
            end
            HOLD_MEM_ADDRESS: begin
                o_debug_read_data = 1;
                o_debug_read_address = mem_address;
                o_tx_start = 0;
                o_tx_data = 0;
                o_done = 0;
            end
            SEND_MEM_BYTE: begin
                o_debug_read_data = 1;
                o_debug_read_address = 0;
                o_tx_start = 1;
                o_tx_data = send_data;
                o_done = 0;
            end
            FINISH: begin
                o_debug_read_data = 0;
                o_debug_read_address = 0;
                o_tx_start = 0;
                o_tx_data = 0;
                o_done = 1;
            end
            default: begin
                o_debug_read_data = 0;
                o_debug_read_address = 0;
                o_tx_start = 0;
                o_tx_data = 0;
                o_done = 0;
                o_debug_read_data = 1;
            end
        endcase
    end

    //inner logic
    always@(posedge clk) begin
        if (!rst) begin
            all_regs_latch <= 0;
            sended_regs_count <= 0;
            mem_address <= 0;
            bytes_count <= 0;
            tx_wait_count <= 0;
        end
        else begin
            case(state)
                IDLE: begin
                    //setup before starting
                    if (i_start) begin
                        all_regs_latch <= all_regs_data;
                        sended_regs_count <= REGS_COUNT;
                        mem_address <= 0;
                        bytes_count <= 0;
                        tx_wait_count <= 0;
                    end
                end
                WAIT_TX_1: begin
                    if (i_tx_done == 0) tx_wait_count <= 0;
                    else                tx_wait_count <= tx_wait_count + 1;
                end
                SEND_REG: begin
                    tx_wait_count <= 0;
                end
                WAIT_TX_2: begin
                    if (i_tx_done == 0) tx_wait_count <= 0;
                    else                tx_wait_count <= tx_wait_count + 1;
                end
                LATCH_REG: begin
                    send_data <= all_regs_latch[ALL_REGS_LEN - 1 -: UART_BITS];
                    all_regs_latch <= all_regs_latch << UART_BITS;
                    sended_regs_count <= sended_regs_count - 1;
                    tx_wait_count <= 0;
                end
                LATCH_MEM_DATA: begin
                    mem_data <= i_mem_data;
                    bytes_count <= 0;
                end
                HOLD_MEM_ADDRESS: begin
                    mem_address <= mem_address + 1;
                end
                LATCH_MEM_BYTE: begin
                    //MSB should be send first
                    send_data <= mem_data[PROC_BITS - 1 -: UART_BITS];
                    mem_data  <= mem_data << UART_BITS;
                    bytes_count <= bytes_count+1;
                    tx_wait_count <= 0;
                end
                WAIT_TX_3: begin
                    if (i_tx_done == 0) tx_wait_count <= 0;
                    else                tx_wait_count <= tx_wait_count + 1;
                end
                SEND_MEM_BYTE: begin
                    tx_wait_count <= 0;
                end
                WAIT_TX_4: begin
                    if (i_tx_done == 0) tx_wait_count <= 0;
                    else                tx_wait_count <= tx_wait_count + 1;
                end
            endcase
        end
    end

endmodule






