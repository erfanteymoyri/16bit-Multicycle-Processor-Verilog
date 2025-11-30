module ALU (
    input wire clk,
    input wire reset,
    input wire start,
    input wire [2:0] opcode,        // 000: add, 001: sub, 010: mul, 011: div
    input wire signed [15:0] a,
    input wire signed [15:0] b,
    output reg signed [15:0] result,
    output reg done
);
    // ADD / SUB logic
    wire signed [15:0] b_negated = ~b + 16'd1;
    wire signed [15:0] b_eff = (opcode == 3'b001) ? b_negated : b;
    wire signed [15:0] add_sub_result;
    wire add_sub_carry;

    CarrySelectAdder16 adder (
        .a(a),
        .b(b_eff),
        .cin(1'b0),
        .sum(add_sub_result),
        .cout(add_sub_carry)
    );

    // MUL logic
    wire signed [15:0] mul_result;
    wire mul_done;

    KaratsubaMultiplier16_Parallel mul (
        .clk(clk),
        .reset(reset),
        .start(start && opcode == 3'b010),
        .a(a),
        .b(b),
        .result(mul_result),
        .done(mul_done)
    );

    // DIV logic
    wire signed [15:0] div_result;
    wire div_done;

    RestoringDivider16 divider (
        .clk(clk),
        .reset(reset),
        .start(start && opcode == 3'b011),
        .a(a),
        .b(b),
        .quotient(div_result),
        .done(div_done)
    );

    // ALU output logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            result <= 16'b0;
            done <= 1'b0;
        end else begin
            done <= 1'b0;  // Default: not done unless explicitly set

            if (start) begin
                case (opcode)
                    3'b000, 3'b001: begin
                        result <= add_sub_result;
                        done <= 1'b1;
                    end
                endcase
            end

            case (opcode)
                3'b010: begin
                    if (mul_done) begin
                        result <= mul_result;
                        done <= 1'b1;
                    end
                end
                3'b011: begin
                    if (div_done) begin
                        result <= div_result;
                        done <= 1'b1;
                    end
                end
            endcase
        end
    end
endmodule