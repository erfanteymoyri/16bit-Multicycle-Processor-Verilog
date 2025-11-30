module controller (
    input clk,
    input rst,
    input [15:0] instr_in,
    input signed [15:0] alu_out,
    input signed [15:0] mem_out,
    input alu_done,
    output reg [1:0] rs1, rs2, rd,
    output reg [2:0] alu_op,
    output reg alu_start,
    output reg rf_write,
    output reg rf_read,
    output reg signed [15:0] rf_write_data,
    output reg [15:0] mem_addr,
    output reg mem_read,
    output reg mem_write,
    output reg [15:0] pc,
    output reg immediate_sel,
    output reg signed [15:0] sign_extended,
    output reg ready
);

    reg [15:0] instr_reg;
    reg [3:0] state;

    localparam FETCH_1    = 0, FETCH_2    = 1,
               DECODE_1   = 2, DECODE_2   = 3,
               EXEC_1     = 4, EXEC_2     = 5,
               MEM_1      = 6, MEM_2      = 7,
               WRITEBK_1  = 8, WRITEBK_2  = 9;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pc <= 0;
            state <= FETCH_1;
            ready <= 0;
            rf_write <= 0;
            rf_read <= 0;
            mem_read <= 1;
            mem_write <= 0;
            alu_start <= 0;
        end else begin
            case (state)
                FETCH_1: begin
                    rf_write <= 0;
                    mem_write <= 0;
                    mem_addr <= pc;
                    mem_read <= 1;
                    state <= FETCH_2;
                    ready <= 0;
                end

                FETCH_2: begin
                    state <= DECODE_1;
                end

                DECODE_1: begin
                    instr_reg <= mem_out;
                    mem_read <= 0;
                    state <= DECODE_2;
                end

                DECODE_2: begin
                    case (instr_reg[15:13])
                        3'b000: alu_op <= 3'b000; // ADD
                        3'b001: alu_op <= 3'b001; // SUB
                        3'b010: alu_op <= 3'b010; // MUL
                        3'b011: alu_op <= 3'b011; // DIV
                        3'b100: alu_op <= 3'b000; // LOAD uses ADD
                        3'b101: alu_op <= 3'b000; // STORE uses ADD
                        default: alu_op <= 3'b000;
                    endcase

                    case (instr_reg[15:13])
                        3'b000, 3'b001, 3'b010, 3'b011: begin
                            rd <= instr_reg[12:11];
                            rs1 <= instr_reg[10:9];
                            rs2 <= instr_reg[8:7];
                            rf_read <= 1;
                            immediate_sel <= 1'b0;
                        end
                        3'b100, 3'b101: begin
                            rd <= instr_reg[12:11];
                            rs1 <= instr_reg[10:9]; // base address
                            rs2 <= instr_reg[8:7];
                            rf_read <= 1;
                            sign_extended <= {{7{instr_reg[8]}}, instr_reg[8:0]};
                            immediate_sel <= 1'b1;
                        end
                    endcase
                    state <= EXEC_1;
                end

                EXEC_1: begin
                    rf_read <= 0;
                    alu_start <= 1;
                    state <= EXEC_2;
                end

                EXEC_2: begin
                    alu_start <= 0;
                    case (instr_reg[15:13])
                        3'b000, 3'b001, 3'b010, 3'b011: begin
                            state <= WRITEBK_1;
                        end
                        3'b100, 3'b101: begin
                            state <= MEM_1;
                        end
                    endcase
                end 

                MEM_1: begin
                    if (alu_done) begin
                        case (instr_reg[15:13])
                            3'b100: begin // LOAD
                                mem_addr <= alu_out;
                                mem_read <= 1;
                                state <= MEM_2;
                            end
                            3'b101: begin // STORE
                                mem_addr <= alu_out;
                                mem_write <= 1;
                                state <= MEM_2;
                            end
                        endcase
                    end
                end

                MEM_2: begin
                    state <= WRITEBK_1;
                    mem_write <= 0;
                end

                WRITEBK_1: begin
                    case (instr_reg[15:13])
                            3'b000, 3'b001: begin // ADD & SUB
                                rf_write_data <= alu_out;
                                rf_write <= 1;
                                state <= WRITEBK_2;
                            end
                            3'b010, 3'b011: begin // MUL & DIV
                                if (alu_done == 1'b1) begin
                                    rf_write_data <= alu_out;
                                    rf_write <= 1;
                                    state <= WRITEBK_2;
                                end
                            end
                            3'b100: begin
                                rf_write_data <= mem_out; // Load
                                rf_write <= 1;
                                state <= WRITEBK_2;
                            end
                            3'b101: begin
                                state <= WRITEBK_2;
                            end
                    endcase
                end

                WRITEBK_2: begin
                    pc <= pc + 16'd1;
                    ready <= 1;
                    state <= FETCH_1;
                end
            endcase
        end
    end
endmodule