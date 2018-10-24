

module Interface
(
    input clk,
    input rst,
    input [15 : 0] accumulator,
    input [7 : 0] inst_count,
    input bip_done,
    output o_tx
);

    wire baud_rate;
    wire tx_done;
    
    reg tx_start;
    reg [7 : 0] tx_data;

    reg next_tx_start;
    reg [7 : 0] next_tx_data;

    reg [2 : 0] state;
    reg [2 : 0] next_state;

    reg [15 : 0] accumulator_latch;
    reg [ 7 : 0] inst_count_latch;


    localparam IDLE = 0;
    localparam SEND_INST_COUNT = 1;
    localparam WAIT1 = 2;
    localparam SEND_ACC_HIGH = 2;
    localparam WAIT2 = 4;
    localparam SEND_ACC_LOW = 5;
    localparam WAIT3 = 5;
    localparam STOP = 6;

    always@(posedge clk) begin
        if(!rst) begin
            state <= 0;
            tx_start <= 0;
            tx_data <= 0;
        end
        else begin
            state <= next_state;
            tx_start <= next_tx_start;
            tx_data <= next_tx_data;
        end
    end


    always@* begin
        next_state = state;
        next_tx_start = 0;
        next_tx_data = 0;

        case(state)
            IDLE:
            begin
                if(bip_done) begin
                    accumulator_latch = accumulator;
                    inst_count_latch = inst_count_latch;
                    next_state = SEND_INST_COUNT;
                end
            end
            
            SEND_INST_COUNT:
            begin
                next_tx_data = inst_count_latch;
                next_tx_start = 1;
                next_state = WAIT1;
            end

            WAIT1:
            begin
                if(tx_done) next_state = SEND_ACC_HIGH;
            end

            SEND_ACC_HIGH:
            begin
                next_tx_data = accumulator[15:8];
                next_tx_start = 1;
                next_state = WAIT2;
            end

            WAIT2:
            begin
                if(tx_done) next_state = SEND_ACC_LOW;
            end

            SEND_ACC_LOW:
            begin
                next_tx_data = accumulator[7:0];
                next_tx_start = 1;
                next_state = WAIT3;
            end

            WAIT3:
            begin
                if(tx_done) next_state = STOP;
            end

            STOP:
            begin
                next_state = STOP;
            end

        endcase
    end


    TX tx_u
    (
        .clk(clk),
        .rst(rst),
        .i_baud_rate(baud_rate),
        .i_tx_start(tx_start),
        .i_data(tx_data),
        .o_tx_done(tx_done),
        .o_tx(o_tx)
    );


    BaudRateGenerator baud_rate_u
    (
        .clk(clk),
        .rst(rst),
        .out(baud_rate)
    );

    
endmodule
