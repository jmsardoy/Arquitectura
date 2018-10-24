`define NBITS 8

module TX(
    input clk,
    input rst,
    input i_baud_rate,
    input i_tx_start,
    input [`NBITS-1 : 0] i_data,
    output reg o_tx_done,
    output reg o_tx);

    localparam NBITS = `NBITS;
    //localparam COUNTER_NBITS = $clog2(NBITS)+1;
    localparam COUNTER_NBITS = 8;

    localparam
        idle  = 'b00,
        start = 'b01,
        data  = 'b11,
        stop  = 'b10;

    reg [1:0] state, next_state;
    reg [3:0] tick_count, next_tick_count;
    reg [COUNTER_NBITS-1 : 0] data_count, next_data_count;
    reg [NBITS - 1 : 0] data_reg, next_data_reg;
    reg next_tx, next_tx_done;


    always@(posedge clk or negedge rst) begin
        if (!rst) begin
            state <= idle;
            tick_count <= 0;
            data_count <= 0;
            data_reg <= 0;
            o_tx_done <= 1;
            o_tx <= 1;
        end
        else begin
            state <= next_state;
            tick_count <= next_tick_count;
            data_count <= next_data_count;
            data_reg <= next_data_reg;
            o_tx_done <= next_tx_done;
            o_tx <= next_tx;
        end
    end


    always@* begin
        
        //defaults
        next_tx = o_tx;
        next_tx_done = o_tx_done;
        next_state = state;
        next_tick_count = tick_count;
        next_data_count = data_count;
        next_data_reg = data_reg;

        case (state)
            
            idle:
            begin
                next_tx = 1;
                next_tx_done = 1;
                if(i_tx_start) begin
                    next_state = start;
                    next_tick_count = 0;
                    next_data_count = 0;
                    next_data_reg = i_data;
                    next_tx_done = 0;
                end
            end

            start:
            begin
                next_tx = 0;
                next_tx_done = 0;
                if (i_baud_rate) begin
                    if(tick_count == 15) begin
                        next_tick_count = 0;
                        next_state = data;
                    end
                    else next_tick_count = tick_count + 1;
                end
            end

            data:
            begin
                if (i_baud_rate) begin
                    if (data_count == NBITS) next_state = stop;
                    else begin
                        if(tick_count == 0) begin
                            next_tx = data_reg[0];
                            next_data_reg = data_reg >> 1;
                        end
                        if (tick_count == 15) begin
                            next_tick_count = 0;
                            next_data_count = data_count + 1;
                        end
                        else next_tick_count = tick_count + 1;
                    end
                end
            end

            stop:
            begin
                next_tx = 1;
                if (i_baud_rate) begin
                    if(tick_count == 15) begin
                        next_state = idle;
                    end
                    else next_tick_count = tick_count + 1;
                end
            end

        endcase
    end
endmodule
