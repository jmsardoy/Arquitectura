`define NBITS 8

module RX
#(
    parameter NBITS = `NBITS
)
(
    input clk,
    input rst,
    input i_baud_rate,
    input i_rx,
    output reg o_rx_done,
    output reg [`NBITS-1 : 0] o_data
);

    localparam COUNTER_NBITS = $clog2(NBITS)+1;
    
    localparam
        idle  = 'b00,
        start = 'b01,
        data  = 'b11,
        stop  = 'b10;

    reg [1:0] state, next_state;
    reg [3:0] tick_count, next_tick_count;
    reg [COUNTER_NBITS-1:0] data_count, next_data_count;
    reg [NBITS-1 : 0] next_data;
    reg next_rx_done;


    always@(posedge clk or negedge rst) begin
        if (!rst) begin
            state <= idle;
            tick_count <= 0;
            data_count <= 0;
            o_data <= {NBITS{1'b0}};
            o_rx_done <= 0; 
        end
        else begin
            state <= next_state;
            tick_count <= next_tick_count;
            data_count <= next_data_count;
            o_data <= next_data;
            o_rx_done <= next_rx_done;
        end
    end


    always@* begin

        //defaults
        next_state = state;
        next_tick_count = tick_count;
        next_data_count = data_count;
        next_data = o_data;
        next_rx_done = 0;

        case (state)

            idle:
            begin
                if (!i_rx) begin
                    next_state = start;
                    next_tick_count = 0;
                    next_data_count = {COUNTER_NBITS{1'b0}};
                    next_data = {NBITS{1'b0}};
                end
            end

            start:
            begin
                if (i_baud_rate) begin
                    if(tick_count == 7) begin
                        next_state = data;
                        next_tick_count = 0;
                    end
                    else next_tick_count = tick_count + 1;
                end
            end

            data:
            begin
                if (i_baud_rate) begin
                    if (data_count == NBITS) next_state = stop;
                    else begin
                        if(tick_count == 15) begin
                            next_data = {i_rx, o_data[NBITS-1:1]};     
                            next_data_count = data_count + 1;
                            next_tick_count = 0;
                        end
                        else next_tick_count = tick_count + 1;
                    end
                end
            end
            
            stop:
            begin
                if (i_baud_rate) begin
                    if (tick_count == 15) begin
                            next_state = idle;
                            next_rx_done = 1;
                        end
                    else next_tick_count = tick_count + 1;
                end
            end
        
        endcase
    
    end

endmodule
