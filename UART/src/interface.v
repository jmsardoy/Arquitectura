
module Interface(
    input clk,
    input rst,
    input i_tx_done,
    input i_rx_done,
    input [7:0] i_rx,
    input [7:0] i_alu_result,
    output reg o_tx_start,
    output reg [7:0] o_tx,
    output reg [7:0] o_alu_a,
    output reg [7:0] o_alu_b,
    output reg [5:0] o_alu_opcode
);

    localparam
        get_a       = 'b00,
        get_b       = 'b01,
        get_opcode  = 'b11,
        send_result = 'b10; 

    reg [1:0] state, next_state;
    reg next_tx_start;
    reg [7:0] next_tx;
    reg [7:0] next_alu_a;
    reg [7:0] next_alu_b;
    reg [5:0] next_alu_opcode;

    always@(posedge clk or negedge rst) begin
        if(!rst) begin
            state <= get_a;
            o_tx_start <= 0;
            o_tx <= 0;
            o_alu_a <= 0;
            o_alu_b <= 0;
            o_alu_opcode <= 0;
        end
        else begin
            state <= next_state;
            o_tx_start <= next_tx_start;
            o_tx <= next_tx;
            o_alu_a <= next_alu_a;
            o_alu_b <= next_alu_b;
            o_alu_opcode <= next_alu_opcode;
        end
    end


    always@* begin

        //defaults
        next_state = state;
        next_tx_start = 0;
        next_tx = o_tx;
        next_alu_a = o_alu_a;
        next_alu_b = o_alu_b;
        next_alu_opcode = o_alu_opcode;

        case (state)
            get_a:
            begin
                if(i_rx_done) begin
                    next_alu_a = i_rx;
                    next_state = get_b;
                end
            end
            get_b:
            begin
                if(i_rx_done) begin
                    next_alu_b = i_rx;
                    next_state = get_opcode;
                end
            end
            get_opcode:
            begin
                if(i_rx_done) begin
                    next_alu_opcode = i_rx[5:0];
                    next_state = send_result;
                end
            end
            send_result:
            begin
                if(i_tx_done) begin
                    next_tx = i_alu_result;
                    next_tx_start = 1;
                    next_state = get_a;
                end
            end
                    
        endcase
    end

    


endmodule
    
