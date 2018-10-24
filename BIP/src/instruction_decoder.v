
module InstructionDecoder
(
	input [4:0] opcode,
    output reg o_enable_pc,
	output reg [1:0] o_sel_a,
	output reg o_sel_b,
	output reg o_write_acc,
	output reg o_operation,
    output reg o_write_mem,
    output reg o_read_mem
);

    localparam HLT  = 'b00000;
    localparam STO  = 'b00001;
    localparam LD   = 'b00010;
    localparam LDI  = 'b00011;
    localparam ADD  = 'b00100;
    localparam ADDI = 'b00101;
    localparam SUB  = 'b00110;
    localparam SUBI = 'b00111;

    always@*begin
        case(opcode)

            HLT: 
            begin
                o_enable_pc <= 0;
                o_sel_a     <= 0;
                o_sel_b     <= 0;
                o_write_acc <= 0;
                o_operation <= 0;
                o_write_mem <= 0;
                o_read_mem  <= 0;
            end

            STO: 
            begin
                o_enable_pc <= 1;
                o_sel_a     <= 0;
                o_sel_b     <= 0;
                o_write_acc <= 0;
                o_operation <= 0;
                o_write_mem <= 1;
                o_read_mem  <= 0;
            end
        
            LD: 
            begin
                o_enable_pc <= 1;
                o_sel_a     <= 0;
                o_sel_b     <= 0;
                o_write_acc <= 1;
                o_operation <= 0;
                o_write_mem <= 0;
                o_read_mem  <= 1;
            end

            LDI: 
            begin
                o_enable_pc <= 1;
                o_sel_a     <= 1;
                o_sel_b     <= 0;
                o_write_acc <= 1;
                o_operation <= 0;
                o_write_mem <= 0;
                o_read_mem  <= 0;
            end

            ADD: 
            begin
                o_enable_pc <= 1;
                o_sel_a     <= 2;
                o_sel_b     <= 0;
                o_write_acc <= 1;
                o_operation <= 0;
                o_write_mem <= 0;
                o_read_mem  <= 1;
            end

            ADDI: 
            begin
                o_enable_pc <= 1;
                o_sel_a     <= 2;
                o_sel_b     <= 1;
                o_write_acc <= 1;
                o_operation <= 0;
                o_write_mem <= 0;
                o_read_mem  <= 0;
            end

            SUB: 
            begin
                o_enable_pc <= 1;
                o_sel_a     <= 2;
                o_sel_b     <= 0;
                o_write_acc <= 1;
                o_operation <= 1;
                o_write_mem <= 0;
                o_read_mem  <= 1;
            end

            SUBI: 
            begin
                o_enable_pc <= 1;
                o_sel_a     <= 2;
                o_sel_b     <= 1;
                o_write_acc <= 1;
                o_operation <= 1;
                o_write_mem <= 0;
                o_read_mem  <= 0;
            end

            default:
            begin
                o_enable_pc <= 0;
                o_sel_a     <= 0;
                o_sel_b     <= 0;
                o_write_acc <= 0;
                o_operation <= 0;
                o_write_mem <= 0;
                o_read_mem  <= 0;
            end

        endcase
        
    end

endmodule
